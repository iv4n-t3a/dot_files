#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(
    # tools
    stow
    git
    gh
    inotify-tools
    gdisk
    flatpak
    openssl
    efitools
    zoxide
    pass

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
    moc

    # dev
    clang
    clang-tools-extra
    golang
    ansible
    python3
    pipx
    gopls

    # python system-wide libs
    python3-matplotlib
    python3-numpy
    python3-torch
    python3-pandas

    # multimedia
    gstreamer1-plugin-openh264
    mozilla-openh264
)

sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y dnf5-plugins
sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo --overwrite # idempotency
sudo dnf install -y "${PACKAGES[@]}"
