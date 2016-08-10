#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Build the deck and configure it
OONI_DECKGEN=$( oonideckgen --output=${OONI_HOME}/decks/ |
	grep ^ooniprobe | cut -d ' ' -f3  ; exit ${PIPESTATUS[0]} )

if [ -n "$OONI_DECKGEN" ]; then
	echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
	echo "OONI_DECK=${OONI_DECKGEN}" >> ${OONI_DECK_CONFIG}
fi

if grep "http_invalid_request_line" ${OONI_DECK}; then
    # Remove http_invalid_request_line test from default deck
    /opt/ooni/massage_deck.py ${OONI_DECK} > ${OONI_DECK}.tmp \
        && ${OONI_DECK}.tmp ${OONI_DECK}
fi
