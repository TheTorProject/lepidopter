#!/bin/bash
echo "$(date) uploading ooniprobe reports" >> /var/log/ooni/oonireport.log
oonireport -f /etc/ooniprobe/oonireport.conf upload \
    >> /var/log/ooni/oonireport.log
