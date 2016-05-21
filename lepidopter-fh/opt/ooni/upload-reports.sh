#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh

oonireport -f ${OONIREPORT_CONFIG} upload
