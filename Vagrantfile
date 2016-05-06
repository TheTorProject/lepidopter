# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
echo "nameserver 8.8.8.8" > /etc/resolv.conf
/root/lepidopter-build/scripts/setup.sh
SETUP

Vagrant.configure("2") do |config|

  # Debian jessie box
  config.vm.box = "debian/contrib-jessie64"

  config.vm.hostname = "lepidopter"

  config.vm.synced_folder ".", "/root/lepidopter-build"

  config.vm.provision :shell, :inline => $setup
end
