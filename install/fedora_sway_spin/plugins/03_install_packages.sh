#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
    # tools
    git
    gh
    inotify-tools
    gdisk
    flatpak
    openssl
    efitools

    # my-de
    alacritty
    flameshot
    neovim
    vifm
    waybar
    zsh
    mpv
    zathura
    zathura-pdf-mupdf
    feh
    gparted

    # dev
    clang
    clang-tools-extra
    golang
)

sudo dnf install -y dnf5-plugins
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo --overwrite # idempotency
sudo dnf install -y "${PACKAGES[@]}"
