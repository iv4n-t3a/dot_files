#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

action="${1:-stow}"
shift 2 || true

packages=(alacritty dunst flameshot moc nvim rofi sway vifm waybar zsh wallpapers)

case "$action" in
  stow)
    exec stow -v -t "$HOME" -d . "${@:-${packages[@]}}" ;;
  unstow|delete)
    exec stow -v -t "$HOME" -d . -D "${@:-${packages[@]}}" ;;
  restow)
    stow -v -t "$HOME" -d . -D "${@:-${packages[@]}}"
    exec stow -v -t "$HOME" -d . "${@:-${packages[@]}}" ;;
  dry-run|preview)
    exec stow -nv -t "$HOME" -d . "${@:-${packages[@]}}" ;;
  list)
    echo "Available packages:"
    for pkg in "${packages[@]}"; do
      echo "  $pkg"
    done ;;
  *)
    echo "Usage: $0 {stow|unstow|restow|dry-run|list} [packages...]"
    exit 1 ;;
esac
