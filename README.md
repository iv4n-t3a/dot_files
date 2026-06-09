# Dot files

![demo](asserts/demo.jpg)

## Packages

| Package | Config path |
|---------|-------------|
| alacritty | `~/.config/alacritty/` |
| dunst | `~/.config/dunst/` |
| flameshot | `~/.config/flameshot/` |
| moc | `~/.moc/` |
| nvim | `~/.config/nvim/` |
| rofi | `~/.config/rofi/` |
| sway | `~/.config/sway/` |
| vifm | `~/.config/vifm/` |
| waybar | `~/.config/waybar/` |
| zsh | `~/.zshrc` |

## Fresh Fedora Sway Spin install

**Prerequisites:** `curl` (pre-installed on Fedora Sway Spin)

```sh
curl -fsSL https://raw.githubusercontent.com/iv4n-t3a/dot_files/main/install/fedora_sway_spin/install.sh | bash
```

The script clones this repo to `~/dot_files`, installs dependencies, sets up the private config repo (VPN etc.), and stows all dotfiles.

## Manual usage

**Prerequisites:** `git`, `stow`

```sh
git clone https://github.com/iv4n-t3a/dot_files ~/dot_files
cd ~/dot_files
```

If you have existing configs, remove or back them up first:

```sh
rm ~/.config/nvim  # example — repeat for each package you want to stow
```

Then stow all packages:

```sh
make stow
```

Or stow a single package:

```sh
stow -t ~ nvim
```

| Command | Description |
|---------|-------------|
| `make stow` | Symlink all packages into `$HOME` |
| `make unstow` | Remove all symlinks |
| `make restow` | Refresh symlinks (unstow + stow) |
| `make dry-run` | Preview what would be linked without applying |
