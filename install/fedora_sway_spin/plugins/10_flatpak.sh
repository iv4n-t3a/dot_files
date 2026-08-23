#!/usr/bin/env bash
set -euo pipefail

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

PACKAGES=(
    org.telegram.desktop
    com.usebruno.Bruno
    org.kde.krita
    org.libreoffice.LibreOffice
    app.zen_browser.zen
)

flatpak install -y "${PACKAGES[@]}"
