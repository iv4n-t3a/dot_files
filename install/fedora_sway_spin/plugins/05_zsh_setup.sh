#!/usr/bin/env bash
set -euo pipefail

sudo chsh -s /bin/zsh root
sudo chsh -s /bin/zsh "$USER"
