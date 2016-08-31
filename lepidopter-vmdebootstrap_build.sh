#!/bin/bash
set -exa
GIT_BUILD="$(git describe --tags)"

echo "LEPIDOPTER_BUILD=\"${GIT_BUILD}\"" > lepidopter-fh/etc/default/lepidopter
source lepidopter-fh/etc/default/lepidopter
source conf/lepidopter-image.conf

vmdebootstrap \
    --arch ${ARCH} \
    --log `pwd`/images/lepidopter-build-${LEPIDOPTER_BUILD}-${ARCH}.log \
    --distribution ${DEB_RELEASE} \
    --apt-mirror ${APT_MIRROR} \
    --mirror ${MIRROR} \
    --image `pwd`/images/lepidopter-${LEPIDOPTER_BUILD}-${ARCH}.img \
    --size 3950M \
    --bootsize 64M \
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
    --package localepurge \
    --package fake-hwclock \
    --package avahi-daemon \
    --configure-apt \
    --customize `pwd`/customize \
    "$@"
