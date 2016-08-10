#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Build the deck and configure it
OONI_DECKGEN=$( oonideckgen --output=${OONI_HOME}/decks/ |
	grep ^ooniprobe | cut -d ' ' -f3  ; exit ${PIPESTATUS[0]} )

# Exclude tests that are disabled from running
python /opt/ooni/exclude_disabled_tests.py ${OONI_DECKGEN}

if [ -n "$OONI_DECKGEN" ]; then
	echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
	echo "OONI_DECK=${OONI_DECKGEN}" >> ${OONI_DECK_CONFIG}
fi
