#!/bin/bash
source /etc/ooniprobe/ooniconfig.sh
trap die ERR

oonireport -f ${OONIREPORT_CONFIG} upload
