#!/bin/sh
set -x

USER="lepidopter"
PASSWD="lepidopter"
DEB_RELEASE="jessie"
HOSTNAME_IMG="lepidopter"
ARCH="armel"
APT_MIRROR="http://httpredir.debian.org/debian"
# Uncomment next line to use apt-cacher-ng
#MIRROR="http://localhost:3142/debian"
MIRROR="http://httpredir.debian.org/debian"
TODAY=`date +%Y%m%d-%H%M`

export APT_MIRROR

vmdebootstrap \
    --arch ${ARCH} \
    --log `pwd`/images/lepidopter-build-${TODAY}-${ARCH}.log \
    --distribution ${DEB_RELEASE} \
    --apt-mirror ${APT_MIRROR} \
    --mirror ${MIRROR} \
    --image `pwd`/images/lepidopter-${TODAY}-${ARCH}.img \
    --size 3900M \
    --bootsize 128M \
    --boottype vfat \
    --log-level debug \
    --verbose \
    --no-extlinux \
    --roottype ext4 \
    --lock-root-password \
    --no-kernel \
    --user ${USER}/${PASSWD} \
    --sudo \
    --hostname ${HOSTNAME_IMG} \
    --enable-dhcp \
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
    --package tcpdump \
    --configure-apt \
    --customize `pwd`/customize \
    "$@"
