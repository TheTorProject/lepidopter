# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup= <<SETUP
PRIORITIES[0]=995
PRIORITIES[1]=750
PRIORITIES[2]=50
PRIORITIES[3]=1

IDX=0
for RELEASE in stable testing unstable experimental;do
  PREF_FILE="/etc/apt/preferences.d/$RELEASE.pref"
  echo "Package: *" > $PREF_FILE
  echo "Pin: release a=$RELEASE" >> $PREF_FILE
  echo "Pin-Priority: ${PRIORITIES[$IDX]}" >> $PREF_FILE
  IDX=$(( $IDX + 1 ))
done
PREF_FILE="/etc/apt/preferences.d/security.pref"
cat <<EOF > $PREF_FILE
Package: *
Pin: release l=Debian-Security
Pin-Priority: 1000
EOF

for RELEASE in stable testing unstable experimental;do
  LIST_FILE="/etc/apt/sources.list.d/$RELEASE.list"
  cat << EOF > $LIST_FILE
deb     http://mirror.steadfast.net/debian/ $RELEASE main contrib non-free
deb-src http://mirror.steadfast.net/debian/ $RELEASE main contrib non-free
deb     http://ftp.us.debian.org/debian/    $RELEASE main contrib non-free
deb-src http://ftp.us.debian.org/debian/    $RELEASE main contrib non-free
EOF
done

LIST_FILE="/etc/apt/sources.list.d/security.list"
cat << EOF > $LIST_FILE
deb     http://security.debian.org/         stable/updates  main contrib non-free
deb     http://security.debian.org/         testing/updates main contrib non-free
EOF
apt-get update
apt-get install -y -t experimental vmdebootstrap
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
