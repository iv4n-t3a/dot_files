#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"

if fc-list | grep -q "JetBrainsMono Nerd Font"; then
    echo "JetBrainsMono Nerd Font already installed, skipping."
    exit 0
fi

echo "Fetching latest Nerd Fonts release..."
VERSION=$(curl -fsSL --max-time 15 https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | grep '"tag_name"' | sed 's/.*"\(v[^"]*\)".*/\1/')

echo "Downloading JetBrainsMono Nerd Font ${VERSION}..."
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL --max-time 300 \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/JetBrainsMono.tar.xz" \
    -o "$TMP/JetBrainsMono.tar.xz"

mkdir -p "$FONT_DIR"
tar -xJf "$TMP/JetBrainsMono.tar.xz" -C "$FONT_DIR"

fc-cache -f "$FONT_DIR"
echo "JetBrainsMono Nerd Font installed."
