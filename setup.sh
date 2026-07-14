#!/bin/sh

USER_SHELL=$(getent passwd "$USER" | cut -d: -f7)

sudo setup-wayland-base
sudo apk add util-linux-login

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11

sudo rc-update add dbus default
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

TARGET_PROFILES="$HOME/.profile"
case "$USER_SHELL" in
    *bash*)
        TARGET_PROFILES="$TARGET_PROFILES $HOME/.bash_profile"
        ;;
    *zsh*)
        TARGET_PROFILES="$TARGET_PROFILES $HOME/.zprofile"
        ;;
esac

printf "Enter your choice (1 for Global XDG Autostart, 2 for Shell Profile): "
read choice

case $choice in
    1)
        sudo mkdir -p /etc/xdg/autostart
        sudo tee /etc/xdg/autostart/pipewire.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=PipeWire
Comment=Start PipeWire and its integrated services
Exec=sh -c "pkill -u $USER -x pipewire; sleep 1; pipewire"
Terminal=false
Type=Application
NoDisplay=true
EOF
        ;;
    2)
        for profile in $TARGET_PROFILES; do
            if [ ! -f "$profile" ]; then
                touch "$profile"
            fi

            if ! grep -q "pgrep -u \"\$USER\" -x \"pipewire\"" "$profile" 2>/dev/null; then
                cat << 'EOF' >> "$profile"

if ! pgrep -u "$USER" -x "pipewire" > /dev/null; then
    pipewire >/dev/null 2>&1 &
fi
EOF
            fi
        done
        ;;
    *)
        echo "Skipping autostart configuration."
        ;;
esac
