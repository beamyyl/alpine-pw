#!/bin/sh
sudo apk add networkmanager networkmanager-wifi networkmanager-tui network-manager-applet dbus
sudo adduser "$USER" plugdev
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/NetworkManager.conf > /dev/null << 'EOF'
[main] 
dhcp=internal
plugins=ifupdown,keyfile

[ifupdown]
managed=true 

[device]
wifi.scan-rand-mac-address=yes
wifi.backend=wpa_supplicant
EOF

sudo tee /etc/NetworkManager/conf.d/any-user.conf > /dev/null << 'EOF'
[main]
auth-polkit=false
EOF

sudo rc-service networking stop 2>/dev/null
sudo rc-service wpa_supplicant stop 2>/dev/null
sudo rc-update del networking boot 2>/dev/null
sudo rc-update del wpa_supplicant boot 2>/dev/null
sudo rc-update add networkmanager default
sudo rc-service networkmanager restart
