#!/bin/bash -e

systemctl enable usizo-splashscreen.service
systemctl enable getty@tty2.service
# fix the wantedby targets
systemctl enable getty@tty1.service
