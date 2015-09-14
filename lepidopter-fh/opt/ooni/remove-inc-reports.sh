#!/bin/bash
oonireport -f /etc/ooniprobe/ooniprobe.conf status |
sed -n -e '/^Incomplete reports/,$s/^\* //p' | while read path; do
    rm -f "$path"
done
