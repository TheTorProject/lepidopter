# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
apt-get update
apt-get install -y binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools
/root/lepidopter-build/lepidopter-generic_build.sh
SETUP

Vagrant.configure("2") do |config|

  # Debian wheezy box
  config.vm.box = "wheezy7.6-amd64"
  config.vm.box_url = "https://github.com/jose-lpa/packer-debian_7.6.0/releases/download/1.0/packer_virtualbox-iso_virtualbox.box"

  config.vm.hostname = "lepidopter"

  config.vm.synced_folder ".", "/root/lepidopter-build"

  config.vm.provision :shell, :inline => $setup
end
