#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
trap die ERR

# Build the deck and configure it
OONI_DECKGEN=$( oonideckgen --output=${OONI_HOME}/decks/ |
	grep ^ooniprobe | cut -d ' ' -f3  ; exit ${PIPESTATUS[0]} )

if [ -n "$OONI_DECKGEN" ]; then
	echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
	echo "OONI_DECK=${OONI_DECKGEN}" >> ${OONI_DECK_CONFIG}
fi
