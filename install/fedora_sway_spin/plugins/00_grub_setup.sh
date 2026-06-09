#!/usr/bin/env bash
set -euo pipefail

echo "Setting GRUB password (default boot entry will remain unrestricted)..."
sudo grub2-setpassword < /dev/tty

echo "Encrypting /boot partition..."
sudo umount -vR /boot
# sudo e2fsck -f /dev/nvme0n1p2
sudo resize2fs -p /dev/nvme0n1p2 992M
sudo cryptsetup reencrypt \
	--encrypt \
	--verbose \
	--type luks2 \
	--pbkdf pbkdf2 \
	--pbkdf-force-iterations 500000 \
	--reduce-device-size 32m \
	/dev/nvme0n1p2

BOOTUUID="$(sudo cryptsetup luksUUID /dev/nvme0n1p2)"
sudo cryptsetup open /dev/nvme0n1p2 luks-"${BOOTUUID}"
sudo mount -va
sudo restorecon -RFv /boot
echo "luks-${BOOTUUID} UUID=${BOOTUUID} none discard" \
    | sudo tee -a /etc/crypttab
sudo cat /etc/crypttab

echo 'GRUB_ENABLE_CRYPTODISK=y' | sudo tee -a /etc/default/grub

echo "Updating grub config..."
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

sudo sed -i "1i cryptomount -u ${BOOTUUID//-/}" /boot/efi/EFI/fedora/grub.cfg

echo "Moving MOK out from /boot ..."
sudo mkdir /opt/efi-backup
sudo mv /boot/efi/EFI/fedora/mmx64.efi /opt/efi-backup
sudo mv /boot/efi/EFI/fedora/mmia32.efi /opt/efi-backup
sudo chmod 600 -R /opt/efi-backup
