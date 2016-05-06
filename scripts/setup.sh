#!/bin/bash

APT_MIRROR="http://httpredir.debian.org/debian"

function usage() {
    echo "usage: setup.sh [options]"
    echo "with no options the script installs the dependencies to run and build
    lepidopter image"
    echo "-c, --compress compress lepidopter image with pxz"
}

while [ $# -ne 0 ]; do
    case $1 in
        -c | --compress)        shift
                                compression=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Compress lepidopter img
compress() {
    apt-get install -y pxz
    pxz -kv -T 4 images/*img
}

append_when_missing() {
    STRING=$1
    DST_FILE=$2
    (test -f $DST_FILE && grep -Fxq "$STRING" $DST_FILE) || echo "$STRING" >> $DST_FILE
}

# Add an apt repository with apt preferences
set_apt_sources() {
    SUITE="$1"
    SUITE_PIN_PRIORITY="$2"
    STABLE_PIN_PRIORITY="$(($2 + 100))"
    COMPONENTS="main"

    read -r -d '' SOURCES <<EOF
# Repository: $SUITE
deb $APT_MIRROR $SUITE $COMPONENTS
deb-src $APT_MIRROR $SUITE $COMPONENTS
EOF

    read -r -d '' PIN_SUITE <<EOF
Package: *
Pin: release n=$SUITE
Pin-Priority: $SUITE_PIN_PRIORITY
EOF

    read -r -d '' PIN_STABLE <<EOF
Package: *
Pin: release n=stable
Pin-Priority: $STABLE_PIN_PRIORITY
EOF

    append_when_missing "$SOURCES" /etc/apt/sources.list
    append_when_missing "$PIN_SUITE" /etc/apt/preferences.d/${SUITE}.pref
    append_when_missing "$PIN_STABLE" /etc/apt/preferences.d/stable.pref
}

# Add sid APT repository
set_apt_sources sid 50
apt-get update

# Bug: Do not install qemu-utils via the sid repo
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes qemu-utils git
DEBIAN_FRONTEND=noninteractive apt-get install -t sid -y --force-yes vmdebootstrap

# Copy know working vmdebootstrap version 0.10 from git
cd $HOME
git clone git://git.liw.fi/vmdebootstrap
cd vmdebootstrap
git checkout tags/vmdebootstrap-0.10
cp vmdebootstrap /usr/sbin/vmdebootstrap

cd $HOME
git clone https://github.com/TheTorProject/lepidopter.git

# Add loop kernel module required to mount loop devices
modprobe loop

cd lepidopter/
./lepidopter-vmdebootstrap_build.sh


if [[ $compression = "1" ]]; then
    compress
fi

# Remove all device mappings
dmsetup remove_all
