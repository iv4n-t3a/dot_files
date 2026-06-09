#!/usr/bin/env bash
set -euo pipefail

sudo install -m 755 "$(dirname "${BASH_SOURCE[0]}")/../../../scripts/goxray-wrapper.sh" /usr/bin/goxray-wrapper

sudo tee /etc/systemd/system/goxray.service > /dev/null <<EOF
[Unit]
Description=goxray tun VPN client
After=network.target

[Service]
ExecStart=/usr/bin/goxray-wrapper
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now goxray

echo "VPN setup complete."
