#!/usr/bin/env bash
set -euo pipefail

PRIVATE_DIR="$HOME/Projects/dot_files_private"
MAPPER="dotfiles_private"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/private-data.sh"
FEDORA_GPG_KEY_URL="https://fedoraproject.org/fedora.gpg"
RELEASES_URL="https://fedoraproject.org/releases.json"

cleanup() {
    sudo umount "/dev/mapper/$MAPPER" 2>/dev/null
    sudo cryptsetup close "$MAPPER" 2>/dev/null
    rm -f "${FIFO1:-}" "${FIFO2:-}"
}
trap cleanup EXIT

# --- pick device ---

echo "Available block devices:"
lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINTS | grep -v loop
echo

read -rp "Enter device to use for both ISO and private data (e.g. sdb): " DEVICE < /dev/tty
[[ -z "$DEVICE" ]] && { echo "No device specified."; exit 1; }
[[ "$DEVICE" == /dev/* ]] && DEV="$DEVICE" || DEV="/dev/$DEVICE"
[[ ! -b "$DEV" ]] && { echo "Not a block device: $DEV"; exit 1; }

echo
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS "$DEV"
echo
read -rp "This will ERASE ALL DATA on $DEV. Type YES to confirm: " CONFIRM < /dev/tty
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }

# --- check if ISO already exists on device ---

if sudo file -s "$DEV" | grep -q "ISO 9660"; then
    echo
    echo "Volume already contains an ISO9660 filesystem (Fedora Sway ISO detected)."
    read -rp "Skip ISO writing step? [Y/n]: " SKIP_ISO < /dev/tty
    if [[ ! "$SKIP_ISO" =~ ^[Nn]$ ]]; then
        SKIP_ISO_WRITE=1
        echo "Skipping ISO write."
    fi
fi

# --- check if LUKS partition already exists ---

PART_NUMS=$(sudo sgdisk -p "$DEV" | awk '/^ +[0-9]+ +/ {print $1}')
if [[ -n "$PART_NUMS" ]]; then
    MAX_PART=$(echo "$PART_NUMS" | sort -n | tail -1)
    PRIV_PART="${DEV}${MAX_PART}"
    if [[ "$DEV" =~ [0-9]$ ]]; then
        PRIV_PART="${DEV}p${MAX_PART}"
    fi

    if sudo cryptsetup isLuks "$PRIV_PART" 2>/dev/null; then
        echo
        echo "Found existing LUKS container on ${PRIV_PART}."
        read -rp "Wipe it and create new LUKS container? [Y/n]: " WIPE_LUKS < /dev/tty
        if [[ "$WIPE_LUKS" =~ ^[Nn]$ ]]; then
            USE_EXISTING_LUKS=1
            echo "Will use existing LUKS container."
        fi
    fi
fi

# --- fetch ISO metadata ---

RELEASE=$(curl -fsSL --max-time 15 "$RELEASES_URL" | python3 -c "
import json, sys
data = json.load(sys.stdin)
sway = [r for r in data
        if r['variant'] == 'Spins'
        and r['subvariant'] == 'Sway'
        and r['arch'] == 'x86_64']
sway.sort(key=lambda r: r['version'], reverse=True)
r = sway[0]
print(r['version'])
print(r['link'])
print(r['sha256'])
print(r['size'])
")

LATEST_VERSION=$(echo "$RELEASE" | sed -n '1p')
LATEST_URL=$(echo "$RELEASE"  | sed -n '2p')
LATEST_SHA=$(echo "$RELEASE"  | sed -n '3p')
LATEST_SIZE=$(echo "$RELEASE" | sed -n '4p')
LATEST_ISO_NAME=$(basename "$LATEST_URL")
LATEST_BUILD=$(echo "$LATEST_ISO_NAME" | grep -oP '\d+\.\d+(?=\.x86_64)')
LATEST_CHECKSUM_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${LATEST_VERSION}/Spins/x86_64/iso/Fedora-Spins-${LATEST_VERSION}-${LATEST_BUILD}-x86_64-CHECKSUM"

# --- function to verify ISO file ---
verify_iso() {
    local iso_file="$1"
    local expected_sha="$2"
    local checksum_file="$3"
    local gpg_key="$4"

    echo "Verifying SHA256..."
    actual_sha=$(sha256sum "$iso_file" | awk '{print $1}')
    if [[ "$actual_sha" != "$expected_sha" ]]; then
        echo "SHA256 mismatch!"
        echo "  expected: $expected_sha"
        echo "  actual:   $actual_sha"
        return 1
    fi

    echo "Verifying GPG signature of checksum file..."
    gpg --verify "$checksum_file" 2>/dev/null || {
        echo "GPG signature verification failed!"
        return 1
    }

    return 0
}

# --- locate or download ISO ---

if [[ "${SKIP_ISO_WRITE:-0}" -eq 1 ]]; then
    echo "Skipping ISO download and write (already present on device)."
else
    ISO_FILE=
    CACHE_DIR="$HOME/.iv4n-t3a_dot_files_cache"
    CACHED_VERSION_FILE="$CACHE_DIR/version.txt"

    mkdir -p $CACHE_DIR

    if [[ -f "$CACHED_VERSION_FILE" ]]; then
        CACHED_VERSION=$(cat "$CACHED_VERSION_FILE")
        ISO_FILE_PATH="$CACHE_DIR/fedora-sway-${CACHED_VERSION}.iso"
        if [[ -f "$ISO_FILE_PATH" ]]; then
            echo "Found cached ISO version: $CACHED_VERSION"
            ISO_FILE="$ISO_FILE_PATH"
        fi
    fi

    if [[ -z "$ISO_FILE" ]]; then
        OLD_ISOS=("$CACHE_DIR"/fedora-sway-*.iso)
        if [[ ${#OLD_ISOS[@]} -eq 1 && -f "${OLD_ISOS[0]}" ]]; then
            OLD_VERSION=$(basename "${OLD_ISOS[0]}" | sed 's/fedora-sway-\(.*\)\.iso/\1/')
            echo "Found older ISO (version $OLD_VERSION)."
            if [[ "$OLD_VERSION" == "$LATEST_VERSION" ]]; then
                echo "Cached ISO is already the latest version ($LATEST_VERSION). Using it."
                ISO_FILE="${OLD_ISOS[0]}"
            else
                echo "Found cached ISO version $OLD_VERSION (latest is $LATEST_VERSION)."
                read -rp "Download new version? [Y/n]: " answer < /dev/tty
                if [[ "$answer" =~ ^[Nn]$ ]]; then
                    echo "Using existing older ISO ($OLD_VERSION)."
                    ISO_FILE="${OLD_ISOS[0]}"
                else
                    echo "Will download new version. Old ISO will be removed after successful download."
                    ISO_FILE=
                fi
            fi
        fi
    fi

    if [[ -z "$ISO_FILE" ]]; then
        echo "Downloading ISO (latest version $LATEST_VERSION)..."
        TMP_CHECKSUM=$(mktemp)
        TMP_GPG=$(mktemp)
        ISO_FILE="$CACHE_DIR/fedora-sway-${LATEST_VERSION}.iso"

        curl -fL --progress-bar --max-time 3600 "$LATEST_URL" -o "$ISO_FILE"
        curl -fsSL --max-time 30 "$LATEST_CHECKSUM_URL" -o "$TMP_CHECKSUM"
        curl -fsSL --max-time 15 "$FEDORA_GPG_KEY_URL" -o "$TMP_GPG"

        echo "Importing Fedora GPG key into temporary keyring..."
        gpg --import "$TMP_GPG" &>/dev/null

        if verify_iso "$ISO_FILE" "$LATEST_SHA" "$TMP_CHECKSUM" "$TMP_GPG"; then
            echo "Download verified."
            echo "$LATEST_VERSION" > "$CACHED_VERSION_FILE"
            find "$CACHE_DIR" -maxdepth 1 -name 'fedora-sway-*.iso' ! -name "$(basename "$ISO_FILE")" -delete
        else
            echo "Download verification failed."
            rm -f "$ISO_FILE"
            exit 1
        fi
        rm -f "$TMP_CHECKSUM" "$TMP_GPG"
    fi

    # --- write ISO to device ---

    echo "Writing ISO to $DEV..."
    if command -v pv >/dev/null 2>&1; then
        pv "$ISO_FILE" | sudo dd of="$DEV" bs=4M oflag=sync conv=fsync status=none
    else
        sudo dd if="$ISO_FILE" of="$DEV" bs=4M status=progress oflag=sync conv=fsync
    fi
fi

# --- create private data partition at end of device ---

if [[ "${USE_EXISTING_LUKS:-0}" -eq 1 ]]; then
    echo "Skipping partition creation (using existing LUKS)."
else
    echo "Creating ${PRIVATE_PART_SIZE:-2G} private data partition at end of $DEV..."

    PRIV_SIZE="${PRIVATE_PART_SIZE:-2G}"

    # --- get real device size ---
    TOTAL_SECTORS=$(sudo blockdev --getsz "$DEV")

    # --- find end sector of the last existing partition ---
    LAST_PART_END=$(sudo sgdisk -p "$DEV" | awk '
      /^ +[0-9]+ +[0-9]+ +[0-9]+/ {end=$3}
      END {print end}
    ')

    if [[ -z "$LAST_PART_END" ]]; then
        echo "No partitions found on $DEV. Creating fresh layout."
        LAST_PART_END=0
    fi

    # --- calculate free sectors ---
    FREE_SECTORS=$((TOTAL_SECTORS - LAST_PART_END - 1))
    if [[ $FREE_SECTORS -lt 0 ]]; then
        echo "ERROR: Partition table extends beyond disk end (corrupt)."
        echo "Run: sudo sgdisk --zap-all $DEV   # ERASES ALL DATA"
        exit 1
    fi

    FREE_BYTES=$((FREE_SECTORS * 512))
    PRIV_BYTES=$(numfmt --from=iec "${PRIVATE_PART_SIZE:-3G}")

    if [[ $FREE_BYTES -lt $PRIV_BYTES ]]; then
        echo "Not enough free space. Free: $((FREE_BYTES/1024/1024)) MiB, Need: ${PRIVATE_PART_SIZE:-3G}"
        exit 1
    fi

    # --- find next available partition number ---

    echo "Repairing disk partition table"
    sudo sgdisk -e "$DEV"

    # Get list of existing partition numbers from the GPT
    PART_NUMS=$(sudo sgdisk -p "$DEV" | awk '/^ +[0-9]+ +/ {print $1}')
    if [[ -z "$PART_NUMS" ]]; then
        NEXT_PART=1
    else
        MAX_PART=$(echo "$PART_NUMS" | sort -n | tail -1)
        NEXT_PART=$((MAX_PART + 1))
    fi

    echo "Next free partition number: $NEXT_PART"

    # --- create private partition ---
    echo "Creating ${PRIVATE_PART_SIZE:-3G} private data partition as ${DEV}${NEXT_PART}..."
    sudo sgdisk --new=${NEXT_PART}:-${PRIVATE_PART_SIZE:-3G}:0 --typecode=${NEXT_PART}:8309 --change-name=${NEXT_PART}:private "$DEV"
    sudo partprobe "$DEV"

    # Determine partition device node
    if [[ "$DEV" =~ [0-9]$ ]]; then
        PRIV_PART="${DEV}p${NEXT_PART}"
    else
        PRIV_PART="${DEV}${NEXT_PART}"
    fi
fi

# --- LUKS format private partition ---

FIFO1=$(mktemp -u)
FIFO2=$(mktemp -u)
mkfifo -m 600 "$FIFO1"
mkfifo -m 600 "$FIFO2"

read -rsp "Enter LUKS passphrase for private data partition: " PASSPHRASE < /dev/tty; echo

if [[ "${USE_EXISTING_LUKS:-0}" -eq 1 ]]; then
    echo -n "$PASSPHRASE" > "$FIFO2" &
    sudo cryptsetup open --key-file "$FIFO2" "$PRIV_PART" "$MAPPER"
else
    echo -n "$PASSPHRASE" > "$FIFO1" &
    sudo cryptsetup luksFormat --batch-mode "$PRIV_PART" "$FIFO1"

    echo -n "$PASSPHRASE" > "$FIFO2" &
    sudo cryptsetup open --key-file "$FIFO2" "$PRIV_PART" "$MAPPER"

    sudo mkfs.ext4 -F "/dev/mapper/$MAPPER"
fi

unset PASSPHRASE

MOUNT=$(mktemp -d)
sudo mount "/dev/mapper/$MAPPER" "$MOUNT"

# --- export private data ---

export_private_data "$MOUNT"

echo "Done. Safely eject the drive before removing it."
