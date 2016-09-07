#!/bin/bash
set -ex

# Set locatime to UTC
cp /usr/share/zoneinfo/UTC /etc/localtime

# Install the updater and cleanup
/updater.py install
rm /updater.py
