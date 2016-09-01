#!/bin/bash
OONI_LOGS="/var/log/ooni"
OONI_CRONJOBS_LOG="${OONI_LOGS}/cronjobs.log"

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
