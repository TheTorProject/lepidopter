#/bin/sh

USER="lepidopter"
PASSWD="lepidopter"
DEB_RELEASE="wheezy"
HOSTNAME_IMG="lepidopter"
APT_MIRROR="http://http.debian.net/debian/"
# apt-cache-ng
#MIRROR="http://localhost:3142/debian"
MIRROR="http://http.debian.net/debian/"

sudo vmdebootstrap \
    --arch armel \
    --log lepidopter-build-`date +%Y%m%d`.log \
    --distribution ${DEB_RELEASE} \
    --apt-mirror ${APT_MIRROR} \
    --mirror ${MIRROR} \
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
    --package less \
    --package openssh-server \
    --package screen \
    --package git-core \
    --package binutils \
    --package ca-certificates \
    --package wget \
    --package kmod \
    --package curl \
    --package haveged \
    --package lsb-release \
    --configure-apt \
    --customize `pwd`/customize
