#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="mybrightness"

# Change the volume using alsa(might differ if you use pulseaudio)
            # brightnessctl set 5%+ | tail -3 | head -1 | awk '{print $4}'
brightness="$(brightnessctl set "$@" | tail -3 | head -1 | awk '{print $4}' | sed "s/[^0-9]//g")"

dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
-h int:value:"$brightness" "Brighness: ${brightness}%"
