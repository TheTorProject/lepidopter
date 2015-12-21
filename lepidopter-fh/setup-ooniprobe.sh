#!/bin/bash
set -ex

TOR_DEB_REPO="http://deb.torproject.org/torproject.org"
TOR_DEB_REPO_SRC_LIST="/etc/apt/sources.list.d/tor.list"
TOR_REPO_GPG="A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89"

# Add Torproject Debian repository
apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys ${TOR_REPO_GPG}
echo "deb ${TOR_DEB_REPO} ${DEB_RELEASE} main" > ${TOR_DEB_REPO_SRC_LIST}

# Install golang-go
apt-get update
apt-get -y -t ${DEB_RELEASE}-backports install golang-go
go version

# Install pluggable transports and dependencies
apt-get -y install libgmp-dev python-pip
# Install obfsproxy and fteproxy
pip install obfsproxy fteproxy
# Build meek-client
export GOPATH=$($mktmp -d)
go get git.torproject.org/pluggable-transports/meek.git/meek-client
cp $GOPATH/bin/meek-client /usr/local/bin/meek-client
chmod +x /usr/local/bin/meek-client
rm -rf $GOPATH
# Install ooniprobe dependencies
apt-get -y install openssl libssl-dev libyaml-dev libsqlite3-dev libffi-dev \
libpcap0.8-dev libgeoip-dev libdumbnet-dev tor tor-geoipdb python-dev
# Install ooniprobe
pip install git+https://github.com/TheTorProject/ooni-probe.git
history -c
