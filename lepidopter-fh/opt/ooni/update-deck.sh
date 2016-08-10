#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Build the deck and configure it
OONI_DECKGEN=$( oonideckgen --output=${OONI_HOME}/decks/ |
	grep ^ooniprobe | cut -d ' ' -f3  ; exit ${PIPESTATUS[0]} )

# Check if http_invalid_request_line test is in default deck
if grep "http_invalid_request_line" ${OONI_DECKGEN}; then
    # Remove http_invalid_request_line test from default deck
    /opt/ooni/massage_deck.py ${OONI_DECKGEN} > ${OONI_DECKGEN}.tmp \
        && mv ${OONI_DECKGEN}.tmp ${OONI_DECKGEN}
fi

if [ -n "$OONI_DECKGEN" ]; then
	echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
	echo "OONI_DECK=${OONI_DECKGEN}" >> ${OONI_DECK_CONFIG}
fi
