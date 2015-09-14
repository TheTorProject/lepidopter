#!/bin/bash
echo "$(date) uploading ooniprobe reports" >> /var/log/ooni/oonireport.log
oonireport -f /etc/ooniprobe/ooniprobe.conf upload \
    >> /var/log/ooni/oonireport.log
