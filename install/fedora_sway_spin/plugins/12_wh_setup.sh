#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/iv4n-t3a/wooordhunt-cli ~/.wh

cd ~/.wh

make install
