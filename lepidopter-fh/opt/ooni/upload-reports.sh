#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
echo "$(date) uploading ooniprobe reports" >> ${OONIREPORT_LOG}
oonireport -f /etc/ooniprobe/oonireport.conf upload >> ${OONIREPORT_LOG}
