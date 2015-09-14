#!/bin/bash
# Install golang-go
apt-get update
apt-get -y -t stretch install golang-go
go version

# Checkout ooniprobe git
git clone https://github.com/TheTorProject/ooni-probe.git \
/opt/ooni/ooni-probe-git/
cd /opt/ooni/ooni-probe-git/
# Install ooniprobe
./scripts/install.sh
history -c
