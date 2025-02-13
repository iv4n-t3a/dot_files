#! /usr/bin/bash

dunst &
syncthing --no-browser &

pipewire &
sleep 2s
wireplumber &
