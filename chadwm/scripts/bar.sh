#!/bin/bash

# ^c$var^ = fg color
# ^b$var^ = bg color

# interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/onedark

cpu() {
    # cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
    cpu_val=$(top -bn 1 | grep -m 1 CPU | awk  '{print $2}')%

    printf "^c$black^ ^b$green^ CPU"
    printf "^c$white^ ^b$grey^ $cpu_val ^b$black^"
}

pkg_updates() {
    updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
    #updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
    # updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

    if [ -z "$updates" ]; then
        printf "  ^c$green^    Fully Updated"
    else
        printf "  ^c$green^    $updates"" updates"
    fi
}

battery() {
    get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
    get_status="$(cat /sys/class/power_supply/BAT0/status)"

    icons=("^c$red^󰂎 ^b$red^^c$black^" "^c$red^󰁺 ^b$red^^c$black^" "󰁻 " "󰁼 " "󰁾 " "󰁾 " "󰁿 " "󰂀 " "󰂁 " "󰂂 " "󰁹 ")
    charging_icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁾" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

    if [ "$get_status" = "Charging" ]; then
        printf "^c$green^ ${charging_icons[${get_capacity::-1}]} ^b$green^^c$black^ ${get_capacity} ^b$black^^c$blue^"
    else
        printf "^c$blue^ ^b$black^ ${icons[${get_capacity::-1}]} ${get_capacity} ^b$black^^c$blue^"
    fi
}

sound () {
    MUTE=$(amixer sget Master | tail -n1 | sed -r "s/.*\[(.*)\]/\1/")
    VOL=$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")
    # MUTE=$(pamixer --get-mute)
    # VOL=$(pamixer --get-volume)


    # if [ "$MUTE" = "true" ]; then
    if [ "$MUTE" = "off" ]; then
        printf "^c$red^󰸈^c$blue^"
    else
        printf "^c$blue^^b$black^"
        if [ "$VOL" -le 33 ]; then
            printf " %s%%" "$VOL"
        elif [ "$VOL" -le 66 ]; then
            printf " %s%%" "$VOL"
        else
            printf " %s%%" "$VOL"
        fi
    fi
}

brightness() {
    printf "^c$red^   "
    printf "^c$red^%.0f\n" $(light)
}

mem() {
    printf "^c$red^^b$black^  "
    printf "^c$red^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g) "
    # printf "^c$red^ $(zramctl | awk '/zram0/ { print $4 }' | sed s/i//g)"
}

wlan() {
    case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
        up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s";;
        down) printf "^c$black^ ^b$red^ 󰤭 ^d^%s";;
        # up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
        # down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
    esac
}

clock() {
    printf "^c$black^ ^b$darkblue^ 󱑆 "
    printf "^c$black^^b$blue^ $(date '+%H:%M')  "
    printf "^c$blue^ ^b$black^"
}

calendar() {
    printf "^c$black^ ^b$darkblue^  "
    printf "^c$black^^b$blue^ $(date '+%a %e.%m')  "
    printf "^c$blue^^b$black^"
}

keyboard(){
    # Получаем значение LED для текущей раскладки
    # Запустите xset -q | grep LED в терминале, чтобы посмотреть значения для каждой раскладки.
    # Значения в этом примере действительны для раскладки us,ru
    T=$(xset -q | grep LED)
    CODE=${T##*mask:  }

    if [ $CODE -eq "00000000" ]; then
        LAYOUT="en"
    fi
    if [ $CODE -eq "00000002" ]; then
        LAYOUT="en(NL)"
    fi
    if [ $CODE -eq "00001000" ]; then
        LAYOUT="ru"
    fi
    if [ $CODE -eq "00001002" ]; then
        LAYOUT="ru(NL)"
    fi

    printf "^c$black^^b$blue^ $LAYOUT ^b$black^"
}

while true; do

    # [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
    # interval=$((interval + 1))
    sleep 1 && xsetroot -name "   $(cpu) $(mem)  $(sound) $(battery)  $(keyboard) $(wlan) $(clock) $(calendar)"
done
