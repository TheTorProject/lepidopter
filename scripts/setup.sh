#!/bin/bash

APT_MIRROR="http://httpredir.debian.org/debian"

function usage() {
    echo "usage: setup.sh [options]"
    echo "with no options the script installs the dependencies to run and build"
         "lepidopter image"
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
function compress() {
apt-get install -y pxz
pxz -kv -D 12 images/*img
}

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
apt-get install -y qemu-utils
apt-get install -t sid -y vmdebootstrap

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


if [ "$compression" = "1" ]; then
    compress
fi

# Remove all device mappings
dmsetup remove_all
