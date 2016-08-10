#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig

if [ -z "${OONI_DECK}" ]; then
   /opt/ooni/update-deck.sh
    source /etc/ooniprobe/oonideckconfig
fi

# Exclude tests that are disabled from running
python /opt/ooni/exclude_disabled_tests.py ${OONI_DECK} 2>> $OONI_LOGS/exclude-tests.log

cd ${OONI_REPORTS}

ooniprobe --annotations=platform:lepidopter --configfile=${OONI_CONFIG} \
    --testdeck=${OONI_DECK}
