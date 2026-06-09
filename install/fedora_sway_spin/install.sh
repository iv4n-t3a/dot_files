#!/usr/bin/env bash
set -eo pipefail

# --- configuration ---
PROJECTS_DIR="$HOME/.dot_files"
REPO_URL="https://github.com/iv4n-t3a/dot_files.git"
export DOTFILES_DIR="${DOTFILES_DIR:-$PROJECTS_DIR/dot_files}"
export DOTFILES_PRIVATE_DIR="${DOTFILES_PRIVATE_DIR:-$PROJECTS_DIR/dot_files_private}"
# ---

# When run via "curl ... | bash", BASH_SOURCE is unset entirely.
# set -u is deferred until after this check to avoid an unbound variable error.
if [[ ! -f "${BASH_SOURCE[0]:-}" ]]; then
    echo "==> Bootstrapping: cloning dot_files..."
    mkdir -p "$PROJECTS_DIR"
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        git -C "$DOTFILES_DIR" pull
    fi
    exec bash "$DOTFILES_DIR/install/install_fedora_sway_spin.sh"
fi

set -u
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$INSTALL_DIR/.." && pwd)"

run_plugins() {
    local dir="$1"
    local plugins=("$dir"/*.sh)
    [[ -e "${plugins[0]}" ]] || return 0

    for plugin in "${plugins[@]}"; do
        echo "==> $(basename "$plugin")"
        bash "$plugin"
    done
}

echo "--- fedora ---"
run_plugins "$INSTALL_DIR/plugins/"

echo "--- stow dotfiles ---"
bash "$DOTFILES_DIR/scripts/stow.sh" stow
