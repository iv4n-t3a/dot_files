#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dot_files/dot_files}"

sudo mkdir -p /etc/vifm
sudo cp "$DOTFILES_DIR/vifm/.config/vifm/favicons.vifm" /etc/vifm/favicons.vifm
