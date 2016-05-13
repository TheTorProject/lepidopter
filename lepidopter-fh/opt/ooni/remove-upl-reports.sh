#!/usr/bin/env bash
# This script removes uploaded OONI report files according to oonireport status
# Removes only reports with not an incomplete or in progress status
source /etc/ooniprobe/ooniconfig.sh
trap die ERR

exl_files=($(oonireport -f ${OONIREPORT_CONFIG} status | sed -n 's/^\* //p'))

for p in `find ${OONI_REPORTS} -name '*.yamloo' -type f`; do
     if ! [[ " ${exl_files[@]} " =~ " ${p} " ]]; then
         rm ${p}
     fi
done
