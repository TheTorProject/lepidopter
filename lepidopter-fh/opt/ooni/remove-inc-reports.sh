#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

oonireport -f ${OONIREPORT_CONFIG} status |
sed -n -e '/^Incomplete reports/,$s/^\* //p' | while read path; do
    rm "$path"
done
