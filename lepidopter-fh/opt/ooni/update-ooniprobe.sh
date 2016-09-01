#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Update ooniprobe
pip install -e --upgrade \
    git+https://github.com/TheTorProject/ooni-probe@v2.0.0-alpha#egg=ooniprobe
