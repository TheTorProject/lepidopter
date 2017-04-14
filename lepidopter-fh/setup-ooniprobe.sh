#!/bin/bash
set -ex

TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
TOR_DEB_REPO_SRC_LIST="/etc/apt/sources.list.d/tor.list"
TOR_REPO_GPG="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"

# Add Torproject Debian repository
apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys ${TOR_REPO_GPG}
echo "deb ${TOR_DEB_REPO} ${DEB_RELEASE} main" > ${TOR_DEB_REPO_SRC_LIST}
apt-get update

# Install ooniprobe and pluggable transports dependencies
apt-get -y install openssl libssl-dev libyaml-dev libffi-dev libpcap-dev tor \
    libgeoip-dev libdumbnet-dev python-dev python-pip libgmp-dev
# Install obfs4proxy that includes a lite version of meek
apt-get -y install -t stretch obfs4proxy

# Remove previous system versions of pyasn1 and python-cryptography
apt-get -y remove python-pyasn1 python-cryptography
# Install obfsproxy, fteproxy and ooniprobe
pip install obfsproxy fteproxy ooniprobe==2.2.0

# Enable ooniprobe systemd service to start on boot
systemctl enable ooniprobe

# Stop running tor service that can lead to a busy chroot mount
service tor stop
history -c
