#!/usr/bin/env bash
set -euo pipefail

# FUCK COPILOT, FUCK MICROSOFT!

sudo systemctl enable keyd --now

sudo dnf copr enable -y alternateved/keyd
sudo dnf install -y keyd

sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/default.conf > /dev/null <<EOF
[ids]
*

[main]
f23+leftshift+leftmeta = layer(control)
EOF

sudo systemctl enable keyd --now
sudo systemctl start keyd
