#!/bin/sh

APT_MIRROR="http://httpredir.debian.org/debian"

# Add an apt repository with apt preferences
set_apt_sources() {
    SUITE="$1"
    PIN_PRIORITY="$2"
    COMPONENTS="main"
    cat <<EOF >> /etc/apt/sources.list
# Repository: $SUITE
deb $APT_MIRROR $SUITE $COMPONENTS
deb-src $APT_MIRROR $SUITE $COMPONENTS
EOF
    cat <<EOF > /etc/apt/preferences.d/${SUITE}.pref
Package: *
Pin: release n=$SUITE
Pin-Priority: $PIN_PRIORITY
EOF
}

# Add sid APT repository
set_apt_sources sid 50
apt-get update

# Bug: Do not install qemu-utils via the sid repo
ept-get install -y qemu-utils
apt-get install -t sid -y vmdebootstrap

cd $HOME
git clone https://github.com/TheTorProject/lepidopter.git

cd lepidopter/
./lepidopter-vmdebootstrap_build.sh
