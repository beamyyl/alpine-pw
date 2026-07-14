#!/bin/sh

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11

sudo rc-update add dbus
sudo rc-service dbus start

sudo cp -a /usr/share/pipewire /etc
sudo cp -a /usr/share/wireplumber /etc

rm -f "$HOME/.config/autostart/pipewire.desktop"
rm -rf "$HOME/.config/pipewire/pipewire.conf.d"
rm -f "$HOME/.config/service/pipewire" "$HOME/.config/service/wireplumber"

printf "Enter your choice (1 for OpenRC User Services, 2 for Shell Profile): "
read choice

case $choice in
    1)
        printf "Choose session type (1 for Wayland/gui, 2 for Xorg/default): "
        read session
        if [ "$session" = "1" ]; then
            RUNLEVEL="gui"
            mkdir -p "$HOME/.config/rc/runlevels/gui"
            mkdir -p "$HOME/.config/rc"
            echo 'rc_env_allow="WAYLAND_DISPLAY"' >> "$HOME/.config/rc/rc.conf"
        else
            RUNLEVEL="default"
            mkdir -p "$HOME/.config/rc/runlevels/default"
        fi
        
        rc-update -U add pipewire "$RUNLEVEL"
        rc-update -U add wireplumber "$RUNLEVEL"
        rc-update -U add pipewire-pulse "$RUNLEVEL"
        ;;
    2)
        CMD='if [ -z "$XDG_RUNTIME_DIR" ]; then export XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"; mkdir -pm 0700 "$XDG_RUNTIME_DIR"; fi; export $(dbus-launch); if ! pgrep -x "pipewire" > /dev/null; then /usr/libexec/pipewire-launcher >/dev/null 2>&1 & fi'
        echo "$CMD" >> "$HOME/.profile"
        echo "$CMD" >> "$HOME/.bash_profile"
        echo "$CMD" >> "$HOME/.zprofile"
        ;;
    *)
        ;;
esac
