#/bin/sh

USER="lepidopter"
PASSWD="lepidopter"
DEB_RELEASE="jessie"
HOSTNAME_IMG="lepidopter"
APT_MIRROR="http://ftp.no.debian.org/debian/"

sudo vmdebootstrap \
    --arch armel \
    --log lepidopter-build-`date +%Y%m%d`.log \
    --distribution ${DEB_RELEASE} \
    --apt-mirror ${APT_MIRROR} \
    --image lepidopter-`date +%Y%m%d`.img \
    --size 3900M \
    --bootsize 64M \
    --boottype vfat \
    --log-level debug \
    --verbose \
    --no-kernel \
    --user ${USER}/${PASSWD} \
    --sudo \
    --hostname ${HOSTNAME_IMG} \
    --enable-dhcp \
    --foreign /usr/bin/qemu-arm-static \
    --package netbase \
    --package ntp \
    --package iproute2 \
    --package less \
    --package openssh-server \
    --package screen \
    --package git-core \
    --package binutils \
    --package ca-certificates \
    --package wget \
    --package curl \
    --package kmod \
    --package curl \
    --package python \
    --package python-dev \
    --package python-setuptools \
    --package build-essential \
    --package libdumbnet1 \
    --package python-dumbnet \
    --package python-libpcap \
    --package tor \
    --package tor-geoipdb \
    --package libgeoip-dev \
    --package libpcap0.8-dev \
    --package libssl-dev \
    --package libffi-dev \
    --package libdumbnet-dev \
    --package tcpdump \
    --package python-pip \
    --configure-apt \
    --customize `pwd`/customize
