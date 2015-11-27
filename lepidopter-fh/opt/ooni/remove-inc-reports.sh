#!/bin/bash
oonireport -f ${OONIREPORT_CONFIG} status |
sed -n -e '/^Incomplete reports/,$s/^\* //p' | while read path; do
    rm -f "$path"
done
