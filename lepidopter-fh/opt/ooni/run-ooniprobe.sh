#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig
trap die ERR

if [ -z "${OONI_DECK}" ]; then
    source /etc/ooniprobe/oonideckconfig
   /opt/ooni/update-deck.sh
fi

cd ${OONI_REPORTS}
echo "$(date) running ooniprobe" >> ${OONI_CRONJOBS_LOG}

ooniprobe -f ${OONI_CONFIG} -i ${OONI_DECK} >> ${OONI_CRONJOBS_LOG}
