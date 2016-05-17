#!/bin/bash
set -ex

TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
TOR_DEB_REPO_SRC_LIST="/etc/apt/sources.list.d/tor.list"
TOR_REPO_GPG="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"

# Add Torproject Debian repository
apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys ${TOR_REPO_GPG}
echo "deb ${TOR_DEB_REPO} ${DEB_RELEASE} main" > ${TOR_DEB_REPO_SRC_LIST}

# Install ooniprobe and pluggable transports dependencies
apt-get -y install openssl libssl-dev libyaml-dev libffi-dev libpcap-dev tor \
    libgeoip-dev libdumbnet-dev python-dev python-pip
# Install golang-go obfs4proxy obfsproxy and fteproxy
# Package obfs4proxy introduces a lite version of meek
apt-get -y install -t stretch golang-go obfs4proxy obfsproxy fteproxy

# Show go version during build-up
go version

# Remove previous system versions of pyasn1 and python-cryptography
apt-get -y remove python-pyasn1 python-cryptography
# Install ooniprobe
pip install git+https://github.com/TheTorProject/ooni-probe.git
history -c
