#!/usr/bin/env bash
set -euo pipefail

echo "Setting GRUB password (default boot entry will remain unrestricted)..."
sudo grub2-setpassword < /dev/tty

echo "Updating grub config..."
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

