#!/usr/bin/env bash
# Private data manifest. Add/remove entries here; both prepare-installation-volume.sh
# and plugins/01_import_private_data.sh read this file — no other changes needed.
#
# Entry format (pipe-separated):
#   gpg          KEY_ID      FILENAME
#   tar          BASE_DIR    SUBPATH    ARCHIVE_NAME
#   tar_sudo     BASE_DIR    SUBPATH    ARCHIVE_NAME    (sudo used to read source)
#   github_binary  OWNER/REPO  FILENAME_ON_VOLUME  INSTALL_PATH

PRIVATE_DATA=(
    "gpg|pass-passwords|pass-passwords.gpg"
    "tar|$HOME|.password-store|pass-store.tar.gz"
    "tar_sudo|/etc|goxray|goxray-config.tar.gz"
    "github_binary|goxray/tun|goxray_cli_linux_amd64|/usr/bin/goxray"
    "tar|$HOME|.mozilla|mozilla.tar.gz"
    "tar|$HOME|.ssh|ssh.tar.gz"
)

export_private_data() {
    local mount="$1"

    for entry in "${PRIVATE_DATA[@]}"; do
        IFS='|' read -r type p1 p2 p3 <<< "$entry"
        case "$type" in
            gpg)
                echo "Exporting GPG key: $p1..."
                gpg --export-secret-keys --armor "$p1" | sudo tee "$mount/$p2" > /dev/null
                sudo chmod 600 "$mount/$p2"
                ;;
            tar)
                echo "Exporting $p1/$p2..."
                tar -czf - -C "$p1" "$p2" | sudo tee "$mount/$p3" > /dev/null
                sudo chmod 600 "$mount/$p3"
                ;;
            tar_sudo)
                echo "Exporting $p1/$p2..."
                sudo tar -czf "$mount/$p3" -C "$p1" "$p2"
                sudo chmod 600 "$mount/$p3"
                ;;
            github_binary)
                echo "Fetching latest $p2 from $p1..."
                local version
                version=$(curl -fsSL --max-time 15 "https://api.github.com/repos/$p1/releases/latest" \
                    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
                curl -fsSL --max-time 300 \
                    "https://github.com/$p1/releases/download/v${version}/$p2" \
                    | sudo tee "$mount/$p2" > /dev/null
                sudo chmod 755 "$mount/$p2"
                ;;
        esac
    done
}

import_private_data() {
    local mount="$1"

    for entry in "${PRIVATE_DATA[@]}"; do
        IFS='|' read -r type p1 p2 p3 <<< "$entry"
        case "$type" in
            gpg)
                if [[ ! -f "$mount/$p2" ]]; then
                    echo "$p2 not found on device"
                    exit 1
                fi
                echo "Importing $p2..."
                gpg --import "$mount/$p2"
                ;;
            tar)
                if [[ -f "$mount/$p3" ]]; then
                    echo "Restoring $p1/$p2..."
                    tar -xzf "$mount/$p3" -C "$p1"
                fi
                ;;
            tar_sudo)
                if [[ -f "$mount/$p3" ]]; then
                    echo "Restoring $p1/$p2..."
                    sudo tar -xzf "$mount/$p3" -C "$p1"
                fi
                ;;
            github_binary)
                echo "Installing $p2 to $p3..."
                sudo install -m 755 "$mount/$p2" "$p3"
                ;;
        esac
    done
}
