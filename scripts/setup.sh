#!/bin/bash
set -e

source lepidopter-fh/etc/default/lepidopter
source conf/lepidopter-image.conf

image_file="lepidopter-${LEPIDOPTER_BUILD}-${ARCH}.img"

function usage() {
    echo "usage: setup.sh [options]"
    echo "with no options the script installs the dependencies and builds" \
            "lepidopter image"
    echo "-c compress lepidopter image with xz or zip compression (eg. -c xz)"
    echo "-t create a torrent file of the image and the digests"
}

while getopts "c:ht" opt; do
    case $opt in
      c)
        compression_method+=("$OPTARG")
        ;;
      t)
        build_torrent=true
        ;;
      h)
        usage
        exit 1
        ;;
     \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        usage
        exit 1
    esac
done

# Create a torrent of the xz image file
mk_torrent() {
apt-get install -y mktorrent bittornado
cd images && \
mktorrent -a 'udp://tracker.torrent.eu.org:451' \
          -a 'udp://tracker.coppersurfer.tk:6969' \
          -n ${image_file:-4} SHA* ${image_file}.xz
btshowmetainfo ${image_file:-4}.torrent
}

# Compress lepidopter img
xz_archive() {
apt-get install -y pxz
pxz --keep --verbose -D 12 images/${image_file}
}

zip_archive() {
apt-get install -y zip
zip --verbose -9 images/${image_file}.zip images/${image_file}
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

if [ "${#compression_method[@]}" -ne 0 ] ; then
    for cmp in "${compression_method[@]}"; do
        ${cmp}_archive
    done
fi

if [ "$build_torrent" = true ] ; then
    mk_torrent
fi

# Remove all device mappings
dmsetup remove_all
