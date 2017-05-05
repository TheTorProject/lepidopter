#!/bin/bash
set -ex

# Set locatime to UTC
cp /usr/share/zoneinfo/UTC /etc/localtime

# Enable lepidopter-update systemd service
systemctl enable lepidopter-update

# Install newest e2fsprogs due to incompatibly with ext4 file system checks
apt-get -y install -t jessie-backports e2fsprogs

# Mount option noatime disables file access writes every time a file is read
sed -i 's/\/ ext4/\/ ext4 defaults,noatime/' /etc/fstab

history -c
