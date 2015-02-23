# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
apt-get update
apt-get install -y debootstrap qemu-utils extlinux kpartx part python-cliapp
wget -O /usr/bin/vmdebootstrap \
http://git.liw.fi/cgi-bin/cgit/cgit.cgi/vmdebootstrap/plain/vmdebootstrap
/root/lepidopter-build/lepidopter-vmdebootstrap_build.sh
SETUP

Vagrant.configure("2") do |config|

  # Debian wheezy box
  config.vm.box = "wheezy7.6-amd64"
  config.vm.box_url = "https://github.com/jose-lpa/packer-debian_7.6.0/releases/download/1.0/packer_virtualbox-iso_virtualbox.box"

  config.vm.hostname = "lepidopter"

  config.vm.synced_folder ".", "/root/lepidopter-build"

  config.vm.provision :shell, :inline => $setup
end
