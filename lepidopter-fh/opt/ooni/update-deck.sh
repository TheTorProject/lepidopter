#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

# Build the deck and configure it
OONI_DECKGEN=$( oonideckgen --output=${OONI_HOME}/decks/ |
	grep ^ooniprobe | cut -d ' ' -f3  ; exit ${PIPESTATUS[0]} )

if [ -n "$OONI_DECKGEN" ]; then
	echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
	echo "OONI_DECK=${OONI_DECKGEN}" >> ${OONI_DECK_CONFIG}
fi

# Remove http_invalid_request_line test from default deck
awk '/http_invalid_request_line/{for(x=NR-9;x<=NR+1;x++)d[x];} \
  {a[NR]=$0} END{for(i=1;i<=NR;i++)if(!(i in d))print a[i]}' ${OONI_DECK} > tmp \
 && mv tmp ${OONI_DECK}
