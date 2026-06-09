#!/usr/bin/env bash
set -euo pipefail

MAPPER="dotfiles_private"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../private-data.sh"

echo "Available block devices:"
lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINTS | grep -v loop
echo

read -rp "Enter device name with private data (e.g. sdb): " DEVICE < /dev/tty

if [[ -z "$DEVICE" ]]; then
    echo "No device specified."
    exit 1
fi

[[ "$DEVICE" == /dev/* ]] && DEV="$DEVICE" || DEV="/dev/$DEVICE"

if [[ ! -b "$DEV" ]]; then
    echo "Not a block device: $DEV"
    exit 1
fi

for i in $(seq 1 20); do
    if [[ "$DEV" =~ [0-9]$ ]]; then
        P="${DEV}p${i}"
    else
        P="${DEV}${i}"
    fi
    if [[ -b "$P" ]] && sudo cryptsetup isLuks "$P" 2>/dev/null; then
        PRIV_PART="$P"
        break
    fi
done

if [[ -z "${PRIV_PART:-}" ]]; then
    echo "No LUKS partition found on $DEV"
    exit 1
fi

echo "Found LUKS container on ${PRIV_PART}. Opening..."
sudo cryptsetup open "$PRIV_PART" "$MAPPER" < /dev/tty

MOUNT=$(mktemp -d)

cleanup() {
    sudo umount "$MOUNT" 2>/dev/null || true
    rmdir "$MOUNT" 2>/dev/null || true
    sudo cryptsetup close "$MAPPER" 2>/dev/null || true
}
trap cleanup EXIT

sudo mount "/dev/mapper/$MAPPER" "$MOUNT"
sudo chown -R "$(id -u):$(id -g)" "$MOUNT"
sudo chmod -R u+r "$MOUNT"
sudo mount -o remount,ro "$MOUNT"

import_private_data "$MOUNT"

# unmount and close before shredding
trap - EXIT
cleanup

echo "Wiping device..."
sudo cryptsetup erase "$PRIV_PART"
sudo shred -n 3 -v "$PRIV_PART"

echo "Import complete, device wiped."
