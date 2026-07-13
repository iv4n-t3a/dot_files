#!/usr/bin/env bash
set -eo pipefail

# --- configuration ---
PROJECTS_DIR="$HOME/.dot_files"
REPO_URL="https://gt.eine-biene.com/iv4n-t3a/dot_files"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dot_files/dot_files}"
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
    exec bash "$DOTFILES_DIR/install/fedora_sway_spin/install.sh"
fi

set -u

run_plugins() {
    local dir="$1"
    local plugins=("$dir"/*.sh)
    local failed=()

    [[ -e "${plugins[0]}" ]] || return 1

    for plugin in "${plugins[@]}"; do
        local name
        name="$(basename "$plugin")"

        echo     "$name: [START] ======================================================"

        if bash "$plugin"; then
            echo "$name: [OK] ========================================================="
        else
            echo "$name: [FAILED] =====================================================" >&2
            failed+=("$name")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo >&2
        echo "--- FAILED PLUGINS (${#failed[@]}) ---" >&2
        printf '  - %s\n' "${failed[@]}" >&2
        return 1   # optionally signal that some failed
    else
        echo "All plugins succeeded."
        return 0
    fi
}

echo "--- fedora ---"
run_plugins "$DOTFILES_DIR/install/fedora_sway_spin/plugins"

echo "--- stow dotfiles ---"
make -C $DOTFILES_DIR stow
