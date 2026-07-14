#!/bin/sh

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11 pam-rundir

sudo rc-update add dbus
sudo rc-service dbus start

sudo adduser "$USER" pipewire

sudo cp -a /usr/share/pipewire /etc
sudo cp -a /usr/share/wireplumber /etc

rm -f "$HOME/.config/autostart/pipewire.desktop"
rm -rf "$HOME/.config/pipewire/pipewire.conf.d"
rm -f "$HOME/.config/service/pipewire" "$HOME/.config/service/wireplumber"

printf "Enter your choice (1 for OpenRC User Services, 2 for Shell Profile): "
read choice

case $choice in
    1)
        mkdir -p "$HOME/.config/rc/runlevels/gui"
        mkdir -p "$HOME/.config/rc/runlevels/default"
        mkdir -p "$HOME/.config/rc"

        if ! grep -q 'rc_env_allow="WAYLAND_DISPLAY"' "$HOME/.config/rc/rc.conf" 2>/dev/null; then
            echo 'rc_env_allow="WAYLAND_DISPLAY"' >> "$HOME/.config/rc/rc.conf"
        fi
        
        rc-update -U add pipewire gui
        rc-update -U add wireplumber gui
        rc-update -U add pipewire-pulse gui

        rc-update -U add pipewire default
        rc-update -U add wireplumber default
        rc-update -U add pipewire-pulse default

        if [ ! -f "$HOME/.xinitrc" ] || ! grep -q "openrc -U default" "$HOME/.xinitrc"; then
            mv "$HOME/.xinitrc" "$HOME/.xinitrc.bak" 2>/dev/null
            cat << 'EOF' > "$HOME/.xinitrc"
openrc -U default
exec dbus-launch --exit-with-session dwm
EOF
            chmod +x "$HOME/.xinitrc"
        fi

        if [ -z "$XDG_RUNTIME_DIR" ]; then
            export XDG_RUNTIME_DIR="/run/user/$(id -u)"
            if [ ! -d "$XDG_RUNTIME_DIR" ]; then
                sudo mkdir -pm 0700 "$XDG_RUNTIME_DIR"
                sudo chown "$USER":"$USER" "$XDG_RUNTIME_DIR"
            fi
        fi

        rc-service -U pipewire start
        rc-service -U wireplumber start
        rc-service -U pipewire-pulse start
        ;;
    2)
        CMD='export $(dbus-launch); if ! pgrep -x "pipewire" > /dev/null; then /usr/libexec/pipewire-launcher >/dev/null 2>&1 & fi'
        echo "$CMD" >> "$HOME/.profile"
        echo "$CMD" >> "$HOME/.bash_profile"
        echo "$CMD" >> "$HOME/.zprofile"
        ;;
    *)
        ;;
esac
