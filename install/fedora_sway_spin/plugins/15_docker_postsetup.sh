#!/usr/bin/env bash
set -euo pipefail

sudo systemctl disable docker.service
sudo systemctl disable docker.socket

# Remove user from docker group for security reasons
sudo gpasswd -d ivan docker || echo "Not in docker group"
