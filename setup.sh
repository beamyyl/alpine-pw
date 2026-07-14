#!/bin/sh

if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/tmp/user-$(id -u)"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
fi

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11

sudo rc-update add dbus
sudo rc-service dbus start

sudo adduser "$USER" pipewire

sudo cp -a /usr/share/pipewire /etc
sudo cp -a /usr/share/wireplumber /etc

rm -f "$HOME/.config/autostart/pipewire.desktop"
rm -rf "$HOME/.config/pipewire/pipewire.conf.d"
rm -f "$HOME/.config/service/pipewire" "$HOME/.config/service/wireplumber"

sudo mkdir -p /etc/pipewire/pipewire.conf.d

sudo tee /etc/pipewire/pipewire.conf.d/10-wireplumber.conf > /dev/null << 'EOF'
context.exec = [
    { path = "/usr/bin/wireplumber" args = "" }
]
EOF

sudo tee /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf > /dev/null << 'EOF'
context.exec = [
    { path = "/usr/bin/pipewire-pulse" args = "" }
]
EOF

for profile in "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.zprofile"; do
    if [ -f "$profile" ] || [ "$profile" = "$HOME/.profile" ]; then
        if ! grep -q "XDG_RUNTIME_DIR" "$profile" 2>/dev/null; then
            cat << 'EOF' >> "$profile"

if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/tmp/user-$(id -u)"
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 0700 "$XDG_RUNTIME_DIR"
    fi
fi
EOF
        fi
    fi
done

printf "Enter your choice (1 for Global XDG Autostart, 2 for Shell Profile): "
read choice

case $choice in
    1)
        sudo mkdir -p /etc/xdg/autostart
        sudo tee /etc/xdg/autostart/pipewire.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=PipeWire
Comment=Start PipeWire and its integrated services
Exec=sh -c "pkill -x pipewire; sleep 1; pipewire"
Terminal=false
Type=Application
NoDisplay=true
EOF
        ;;
    2)
        for profile in "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.zprofile"; do
            if [ -f "$profile" ] || [ "$profile" = "$HOME/.profile" ]; then
                if ! grep -q "pgrep -x \"pipewire\"" "$profile" 2>/dev/null; then
                    cat << 'EOF' >> "$profile"

if ! pgrep -x "pipewire" > /dev/null; then
    pipewire >/dev/null 2>&1 &
fi
EOF
                fi
            fi
        done
        ;;
    *)
        ;;
esac
