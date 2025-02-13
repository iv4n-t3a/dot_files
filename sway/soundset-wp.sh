#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

# Change the volume using alsa(might differ if you use pulseaudio)
wpctl set-mute @DEFAULT_SINK@ 0
wpctl set-volume -l 1 @DEFAULT_SINK@ "$@"

# Query amixer for the current volume and whether or not the speaker is muted
volume="$(wpctl get-volume @DEFAULT_SINK@ | awk '{print $2 * 100}')"
mute="$(wpctl get-volume @DEFAULT_SINK@ | awk '{print $3}')"
dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
-h int:value:"$volume" "Volume: ${volume}%"
