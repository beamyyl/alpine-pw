#!/bin/sh

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11[cite: 1]

sudo rc-update add dbus[cite: 1]
sudo rc-service dbus start[cite: 1]

sudo adduser "$USER" pipewire[cite: 1]

sudo cp -a /usr/share/pipewire /etc[cite: 1]
sudo cp -a /usr/share/wireplumber /etc[cite: 1]

rm -f "$HOME/.config/autostart/pipewire.desktop"[cite: 1]
rm -rf "$HOME/.config/pipewire/pipewire.conf.d"[cite: 1]
rm -f "$HOME/.config/service/pipewire" "$HOME/.config/service/wireplumber"[cite: 1]

printf "Enter your choice (1 for OpenRC User Services, 2 for Shell Profile): "
read choice

case $choice in
    1)
        mkdir -p "$HOME/.config/rc/runlevels/gui"[cite: 1]
        mkdir -p "$HOME/.config/rc/runlevels/default"[cite: 1]
        mkdir -p "$HOME/.config/rc"[cite: 1]

        if ! grep -q 'rc_env_allow="WAYLAND_DISPLAY"' "$HOME/.config/rc/rc.conf" 2>/dev/null; then[cite: 1]
            echo 'rc_env_allow="WAYLAND_DISPLAY"' >> "$HOME/.config/rc/rc.conf"[cite: 1]
        fi
        
        rc-update -U add pipewire gui[cite: 1]
        rc-update -U add wireplumber gui[cite: 1]
        rc-update -U add pipewire-pulse gui[cite: 1]

        rc-update -U add pipewire default[cite: 1]
        rc-update -U add wireplumber default[cite: 1]
        rc-update -U add pipewire-pulse default[cite: 1]

        if [ ! -f "$HOME/.xinitrc" ] || ! grep -q "openrc -U default" "$HOME/.xinitrc"; then[cite: 1]
            mv "$HOME/.xinitrc" "$HOME/.xinitrc.bak" 2>/dev/null[cite: 1]
            cat << 'EOF' > "$HOME/.xinitrc"
if [ -z "$XDG_RUNTIME_DIR" ]; then[cite: 1]
    export XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"[cite: 1]
    mkdir -pm 0700 "$XDG_RUNTIME_DIR"[cite: 1]
fi

openrc -U default[cite: 1]

exec dbus-launch --exit-with-session dwm[cite: 1]
EOF
            chmod +x "$HOME/.xinitrc"[cite: 1]
        fi

        if [ -z "$XDG_RUNTIME_DIR" ]; then[cite: 1]
            export XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"[cite: 1]
            mkdir -pm 0700 "$XDG_RUNTIME_DIR"[cite: 1]
        fi

        rc-service -U pipewire start[cite: 1]
        rc-service -U wireplumber start[cite: 1]
        rc-service -U pipewire-pulse start[cite: 1]
        ;;
    2)
        CMD='if [ -z "$XDG_RUNTIME_DIR" ]; then export XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"; mkdir -pm 0700 "$XDG_RUNTIME_DIR"; fi; export $(dbus-launch); if ! pgrep -x "pipewire" > /dev/null; then /usr/libexec/pipewire-launcher >/dev/null 2>&1 & fi'[cite: 1]
        echo "$CMD" >> "$HOME/.profile"[cite: 1]
        echo "$CMD" >> "$HOME/.bash_profile"[cite: 1]
        echo "$CMD" >> "$HOME/.zprofile"[cite: 1]
        ;;
    *)
        ;;
esac
