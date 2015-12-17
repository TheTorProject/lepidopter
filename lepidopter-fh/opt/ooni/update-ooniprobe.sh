#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Update ooniprobe
pip -q install ooniprobe --upgrade
# Update ooniresources
ooniresources --update-inputs
