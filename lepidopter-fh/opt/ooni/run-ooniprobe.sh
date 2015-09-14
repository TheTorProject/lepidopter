#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
cd /opt/ooni/reports/
echo "$(date) running ooniprobe" >> /var/log/ooni/cronjobs.log

if [ -z "$OONI_DECK" ]
  then
    /opt/ooni/update-deck.sh
    source /etc/ooniprobe/ooniconfig.sh
fi

flock -n /run/ooniprobe.daily.lock -c "ooniprobe -f $OONI_CONFIG \
    -i $OONI_DECK" >> /var/log/ooni/cronjobs.log
