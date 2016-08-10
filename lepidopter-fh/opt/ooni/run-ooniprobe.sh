#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
source /etc/ooniprobe/oonideckconfig

if [ -z "${OONI_DECK}" ]; then
   /opt/ooni/update-deck.sh
    source /etc/ooniprobe/oonideckconfig
fi

# Check if http_invalid_request_line test is in default deck
if grep "http_invalid_request_line" ${OONI_DECK}; then
    # Remove http_invalid_request_line test from default deck
    /opt/ooni/massage_deck.py ${OONI_DECK} > ${OONI_DECK}.tmp \
        && mv ${OONI_DECK}.tmp ${OONI_DECK}
fi

cd ${OONI_REPORTS}

ooniprobe --annotations=platform:lepidopter --configfile=${OONI_CONFIG} \
    --testdeck=${OONI_DECK}
