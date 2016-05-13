#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig
trap die ERR

if [ -z "${OONI_DECK}" ]; then
    source /etc/ooniprobe/oonideckconfig
   /opt/ooni/update-deck.sh
fi

cd ${OONI_REPORTS}

ooniprobe --anotations=platform:lepidopter --confifile=${OONI_CONFIG} \
    --testdeck=${OONI_DECK}
