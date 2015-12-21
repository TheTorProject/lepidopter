#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
echo "$(date) uploading ooniprobe reports" >> ${OONIREPORT_LOG}
oonireport -f ${OONIREPORT_CONFIG} upload >> ${OONIREPORT_LOG}
