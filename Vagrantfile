# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
echo "nameserver 8.8.8.8" > /etc/resolv.conf
/root/lepidopter-build/scripts/setup.sh
SETUP

Vagrant.configure("2") do |config|

  # Debian wheezy box
  config.vm.box = "trusty32"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"

  config.vm.hostname = "lepidopter"

  config.vm.synced_folder ".", "/root/lepidopter-build"

  config.vm.provision :shell, :inline => $setup
end
