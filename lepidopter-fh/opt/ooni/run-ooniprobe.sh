#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig
trap die ERR

cd ${OONI_REPORTS}
echo "$(date) running ooniprobe" >> ${OONI_CRONJOBS_LOG}

if [ -z "${OONI_DECK}" ]; then
   /opt/ooni/update-deck.sh
fi

ooniprobe -f ${OONI_CONFIG} -i ${OONI_DECK} >> ${OONI_CRONJOBS_LOG}
