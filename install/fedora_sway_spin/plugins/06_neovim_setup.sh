#!/usr/bin/env bash
set -euo pipefail

# nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi

. "$HOME/.nvm/nvm.sh"

if ! node --version 2>/dev/null | grep -q "^v24"; then
    echo "Installing Node.js 24..."
    nvm install 24
fi

# packer.nvim
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [[ ! -d "$PACKER_DIR" ]]; then
    echo "Installing packer.nvim..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
fi
