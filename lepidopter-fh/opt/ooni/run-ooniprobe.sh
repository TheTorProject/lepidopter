#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig

if [ -z "${OONI_DECK}" ]; then
   /opt/ooni/update-deck.sh
    source /etc/ooniprobe/oonideckconfig
fi

cd ${OONI_REPORTS}

ooniprobe --annotations=platform:lepidopter --configfile=${OONI_CONFIG} \
    --testdeck=${OONI_DECK}
