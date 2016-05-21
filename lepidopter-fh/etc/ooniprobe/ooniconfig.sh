#!/bin/bash
OONI_CONFIG="/etc/ooniprobe/ooniprobe.conf"
OONI_HOME="/opt/ooni"
OONI_REPORTS="/opt/ooni/reports"
OONI_DECK_CONFIG="/etc/ooniprobe/oonideckconfig"
OONI_CRONJOBS_LOG="/var/log/ooni/cronjobs.log"
OONIREPORT_LOG="/var/log/ooni/oonireport.log"
OONIREPORT_CONFIG="/etc/ooniprobe/oonireport.conf"

datestamp=$(date -u +"%d-%m-%y %R")

# Immediatellly lock any script that sources this file
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -e "$0" "$0" "$@" || :

# Better error handling. Log which script failed and where.
die()
{
  echo "${datestamp} error in \"$0\" at line $BASH_LINENO" \
      >> ${OONI_CRONJOBS_LOG}
  exit 1
}

# Log all STDERR
exec 2>> ${OONI_CRONJOBS_LOG}

trap die ERR SIGTERM SIGINT
