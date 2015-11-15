#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig
cd ${OONI_REPORTS}
echo "$(date) running ooniprobe" >> ${OONI_CRONJOBS_LOG}

if [ -z "${OONI_DECK}" ]
then
    /opt/ooni/update-deck.sh
    source /etc/ooniprobe/ooniconfig.sh
fi

flock -n /run/ooniprobe.daily.lock -c \
    "ooniprobe -f ${OONI_CONFIG} -i ${OONI_DECK}" >> ${OONI_CRONJOBS_LOG}
