# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
apt-get update
apt-get install -y debootstrap qemu-utils extlinux kpartx parted python-cliapp mbr
wget -O /usr/bin/vmdebootstrap \
http://git.liw.fi/cgi-bin/cgit/cgit.cgi/vmdebootstrap/plain/vmdebootstrap
chmod +x /usr/bin/vmdebootstrap
cd /root/lepidopter-build/images/
/root/lepidopter-build/lepidopter-vmdebootstrap_build.sh
SETUP

Vagrant.configure("2") do |config|

  # Debian wheezy box
  config.vm.box = "trusty32"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"

  config.vm.hostname = "lepidopter"

  config.vm.synced_folder ".", "/root/lepidopter-build"

  config.vm.provision :shell, :inline => $setup
end
