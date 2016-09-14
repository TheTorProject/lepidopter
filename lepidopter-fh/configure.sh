#!/bin/bash
set -ex

# Set locatime to UTC
cp /usr/share/zoneinfo/UTC /etc/localtime

# Enable lepidopter-update systemd service
systemctl enable lepidopter-update

history -c
