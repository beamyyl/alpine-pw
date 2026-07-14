#!/bin/sh

sudo apk add pipewire wireplumber pipewire-pulse pipewire-alsa pipewire-jack pavucontrol dbus dbus-x11 util-linux-login

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
