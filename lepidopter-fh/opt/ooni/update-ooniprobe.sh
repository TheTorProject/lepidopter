#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
trap die ERR

# Make sure to remove python-cryptography package that intereferes with many
# python packages and system upgrades
apt-get -y -qq purge python-cryptography

# Update ooniprobe
pip -q install ooniprobe --upgrade
# Update ooniresources
ooniresources --update-inputs
