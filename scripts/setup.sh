#!/bin/sh

apt-get update

apt-get install -y debootstrap qemu-utils extlinux kpartx parted python-cliapp \
  mbr python-distro-info binfmt-support \
  qemu qemu-user-static lvm2 dosfstools git

wget -O /usr/sbin/vmdebootstrap \
  http://git.liw.fi/cgi-bin/cgit/cgit.cgi/vmdebootstrap/plain/vmdebootstrap

chmod +x /usr/sbin/vmdebootstrap

cd $HOME
git clone https://github.com/TheTorProject/lepidopter.git

cd lepidopter/
./lepidopter-vmdebootstrap_build.sh
