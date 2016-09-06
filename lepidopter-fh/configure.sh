#!/bin/bash
set -ex

# Set locatime to UTC
cp /usr/share/zoneinfo/UTC /etc/localtime

# Checkout lepidopter-update repo
git clone https://github.com/OpenObservatory/lepidopter-update \
    /opt/ooni/lepidopter-update

# Enable lepidopter-update systemd service
systemctl enable lepidopter-update
