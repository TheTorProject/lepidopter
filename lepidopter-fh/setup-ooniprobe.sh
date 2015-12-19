#!/bin/bash
set -ex

# Install golang-go
apt-get update
apt-get -y -t stretch install golang-go
go version

# Install pip and ooniprobe dependencies
apt-get -y install openssl libssl-dev libyaml-dev libsqlite3-dev \
libffi-dev python-pip libpcap0.8-dev
# Install ooniprobe
pip install git+https://github.com/TheTorProject/ooni-probe.git
history -c
