#!/bin/bash

msgTag="myvolume"

wpctl set-mute @DEFAULT_SINK@ toggle

volume="$(wpctl get-volume @DEFAULT_SINK@ | awk '{print $2 * 100}')"
mute="$(wpctl get-volume @DEFAULT_SINK@ | awk '{print $3}')"

if [[ "$mute" == "[MUTED]" ]]; then
    dunstify -a "changeVolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:$msgTag "Volume muted"
else
    dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
    -h int:value:"$volume" "Volume: ${volume}%"
fi
