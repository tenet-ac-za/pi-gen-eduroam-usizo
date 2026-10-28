systemctl enable usizo-wifi
systemctl mask wpa_supplicant.service
systemctl enable wpa_supplicant@wlan0.service
systemctl mask dhcpcd.service
systemctl enable dhcpcd@wlan0.service
