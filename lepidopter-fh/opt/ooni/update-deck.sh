#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

echo "$(date) Updating deck" >> ${OONI_CRONJOBS_LOG}
# Build the deck and configure it 
cd ${OONI_HOME}
OONI_DECK=$(oonideckgen -o decks/ | tee -a ${OONI_CRONJOBS_LOG} |
 grep ^ooniprobe | cut -d ' ' -f3)
echo "#ooniprobe deck update: $(date)" > ${OONI_DECK_CONFIG}
echo "OONI_DECK=${OONI_DECK}" >> ${OONI_DECK_CONFIG}
echo "$(date) done updating deck" >> ${OONI_CRONJOBS_LOG}
