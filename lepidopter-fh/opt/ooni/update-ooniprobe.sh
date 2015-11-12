#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Update ooniprobe
pip -q install ooniprobe --upgrade
# Hack: downgrade Twisted
pip -q install 'Twisted>=12.2.0,<=14.0.0'
# Update ooniresources
ooniresources --update-inputs
