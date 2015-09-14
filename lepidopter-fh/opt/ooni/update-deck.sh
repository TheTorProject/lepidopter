#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

echo "$(date) Updating deck" >> /var/log/ooni/cronjobs.log
# Build the deck and configure it 
cd ${OONI_HOME}
OONI_DECK=$(oonideckgen -o decks/ | tee -a /var/log/ooni/cronjobs.log |
 grep ^ooniprobe | cut -d ' ' -f3)
echo "OONI_HOME=${OONI_HOME}" >> /etc/ooniprobe/ooniconfig.sh.tmp
echo "OONI_CONFIG=${OONI_CONFIG}" >> /etc/ooniprobe/ooniconfig.sh.tmp
echo "OONI_DECK=${OONI_DECK}" >> /etc/ooniprobe/ooniconfig.sh.tmp
mv /etc/ooniprobe/ooniconfig.sh.tmp /etc/ooniprobe/ooniconfig.sh
chmod +x /etc/ooniprobe/ooniconfig.sh
echo "$(date) done updating deck" >> /var/log/ooni/cronjobs.log
