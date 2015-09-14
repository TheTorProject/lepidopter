#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
# Hack: downgrade Twisted
pip -q uninstall -y Twisted
pip -q install 'Twisted>=12.2.0,<=14.0.0'

pip -q install ooniprobe --upgrade
ooniresources --update-inputs
