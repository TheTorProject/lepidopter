#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
trap die ERR

# Update ooniprobe
pip -q install ooniprobe --upgrade
# Update ooniresources
ooniresources --update-inputs
