#!/bin/bash
#
#
# Required Packages
# binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools

#set -e # Exit on first error
set -x # Enable debugging

OONIPROBE_PATH="/root/ooni-probe"

deb_mirror="http://ftp.fi.debian.org/debian/"
# Apt-Cacher NG caching
#deb_local_mirror="http://localhost:3142/debian"

bootsize="64M"

# Image size in MB
deb_image_size="3600"

HOSTNAME="lepidopter"

# Generate Root password
PASSWD="lepidopter"
deb_release="wheezy"

device=$1
buildenv="/root/lepidopter-build"
rootfs="${buildenv}/rootfs"
bootfs="${rootfs}/boot"

mydate=`date +%Y%m%d`

if [ "${deb_local_mirror}" == "" ]; then
  deb_local_mirror=${deb_mirror}
fi

image=""


if [ $EUID -ne 0 ]; then
  echo "this tool must be run as root"
  exit 1
fi

if ! [ -b ${device} ]; then
  echo "${device} is not a block device"
  exit 1
fi

if [ "${device}" == "" ]; then
  echo "no block device given, just creating an image"
  mkdir -p ${buildenv}
  image="${buildenv}/lepidopter_${deb_release}_${mydate}.img"
  dd if=/dev/zero of=${image} bs=1MB count=${deb_image_size}
  device=`losetup -f --show ${image}`
  echo "image ${image} created and mounted as ${device}"
else
  dd if=/dev/zero of=${device} bs=512 count=1
fi

fdisk ${device} << EOF
n
p
1

+${bootsize}
t
c
n
p
2


w
EOF


if [ "${image}" != "" ]; then
  losetup -d ${device}
  device=`kpartx -va ${image} | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
  device="/dev/mapper/${device}"
  bootp=${device}p1
  rootp=${device}p2
else
  if ! [ -b ${device}1 ]; then
    bootp=${device}p1
    rootp=${device}p2
    if ! [ -b ${bootp} ]; then
      echo "uh, oh, something went wrong, can't find bootpartition neither as
      ${device}1 nor as ${device}p1, exiting."
      exit 1
    fi
  else
    bootp=${device}1
    rootp=${device}2
  fi
fi

mkfs.vfat ${bootp}
mkfs.ext4 ${rootp}

mkdir -p ${rootfs}

mount ${rootp} ${rootfs}

mkdir -p ${rootfs}/proc
mkdir -p ${rootfs}/sys
mkdir -p ${rootfs}/dev
mkdir -p ${rootfs}/dev/pts

cd ${rootfs}

debootstrap --foreign --arch armel ${deb_release} ${rootfs} ${deb_local_mirror}
cp /usr/bin/qemu-arm-static usr/bin/
LANG=C chroot ${rootfs} /debootstrap/debootstrap --second-stage

mount ${bootp} ${bootfs}

echo "deb ${deb_local_mirror} ${deb_release} main contrib non-free
" > etc/apt/sources.list

echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200
console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait" > boot/cmdline.txt

echo "proc            /proc           proc    defaults        0       0
/dev/mmcblk0p1  /boot           vfat    defaults        0       0
" > etc/fstab

echo "${HOSTNAME}" > etc/hostname

echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
" > etc/network/interfaces

echo "vchiq" >> etc/modules

#echo "console-common	console-data/keymap/policy	select	Select keymap from full list
#console-common console-data/keymap/full	select	de-latin1-nodeadkeys
#" > debconf.set

(
cat <<'EOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
#debconf-set-selections /debconf.set
#rm -f /debconf.set
apt-get update
apt-get -y install git-core binutils ca-certificates curl locales \
console-common ntp openssh-server less parted keyboard-configuration

curl https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -o \
/usr/bin/rpi-update

chmod +x /usr/bin/rpi-update
mkdir -p /lib/modules/3.1.9+
touch /boot/start.elf
SKIP_BACKUP=1 rpi-update

# Too fast, causes segmentation fault
sleep 5s

curl -o /sbin/raspi-config \
https://github.com/anadahz/raspi-config_lepidopter/raw/master/raspi-config

chmod +x /sbin/raspi-config

# Building ooniprobe
echo "deb http://deb.torproject.org/torproject.org/ wheezy main" \
>> /etc/apt/sources.list
gpg --keyserver keys.gnupg.net --keyserver-options timeout=120 --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
apt-get update
apt-get -y install lsb-release sudo screen tcpdump tor tor-geoipdb
git clone https://github.com/TheTorProject/ooni-probe.git \"${OONIPROBE_PATH}\"
cd \"${OONIPROBE_PATH}\"
./setup-dependencies.sh -p -y
python setup.py install

echo \"root:\"${PASSWD}\"\" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' \
/lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
history -c
EOF
) > third-stage
chmod +x third-stage
LANG=C chroot ${rootfs} /third-stage
rm -f third-stage

#echo "deb ${deb_mirror} ${deb_release} main contrib non-free" \
#> etc/apt/sources.list

# rc.local
(
cat <<'EOF'
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "${_IP}" ]; then
  printf "My IP address is %s\n" "${_IP}"
fi

exit 0
EOF
) > etc/rc.local


# regenerate_ssh_host_keys
(
cat <<'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          regenerate_ssh_host_keys
# Required-Start:
# Required-Stop:
# Default-Start: 2
# Default-Stop:
# Short-Description: Regenerate ssh host keys
# Description:
### END INIT INFO

. /lib/lsb/init-functions

set -e

case "$1" in
  start)
    log_daemon_msg "Regenerating ssh host keys in background..."
    nohup sh -c "yes | ssh-keygen -q -N '' -t dsa -f \
     /etc/ssh/ssh_host_dsa_key && yes | ssh-keygen -q -N '' -t rsa -f \
     /etc/ssh/ssh_host_rsa_key && yes | ssh-keygen -q -N '' -t ecdsa -f \
     /etc/ssh/ssh_host_ecdsa_key && update-rc.d ssh enable && sync && \
     rm /etc/init.d/regenerate_ssh_host_keys && \
     update-rc.d regenerate_ssh_host_keys remove && \
     printf '\nfinished\n' && invoke-rc.d ssh start" \
     > /var/log/regen_ssh_keys.log 2>&1 &
    log_end_msg $?
    ;;
  *)
    log_success_msg "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
) > etc/init.d/regenerate_ssh_host_keys

(
cat <<'EOF'
#!/bin/bash
# Re-enables at first boot after regeneration of ssh host keys
update-rc.d ssh disable
rm -f /etc/ssh/ssh_host_*_key*
chmod +x /etc/init.d/regenerate_ssh_host_keys
update-rc.d regenerate_ssh_host_keys start 2
history -c
EOF
) > remove_ssh_host_keys

chmod +x remove_ssh_host_keys
LANG=C chroot ${rootfs} /remove_ssh_host_keys
rm -f remove_ssh_host_keys

(
cat <<'EOF'
#!/bin/bash
apt-get clean
printf "\nCleaning up...\n"
sleep 4s;
history -c
EOF
) > cleanup

chmod +x cleanup
LANG=C chroot ${rootfs} /cleanup
rm -f cleanup

cd

sync
sleep 15

umount -l ${bootp}
umount -l ${rootp}
# Remove device mappings. Avoid running out of loop devices.
dmsetup remove_all

if [ "${image}" != "" ]; then
  kpartx -d ${image}
  echo "created image ${image}"
  echo "The root pass: ${PASSWD}"
fi

echo "done."
