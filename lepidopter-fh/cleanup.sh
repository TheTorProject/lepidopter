#!/usr/bin/env bash
set -ex

# Clean up the local repository of retrieved package files
apt-get clean
apt-get autoclean

# Delete /var/log files
find /var/log -type f -delete

# Remove the same set of files and directories
# in the project-config's postinst.
if [ "$1" = "configure" ] && [ -z "$2" ]; then
    echo "Removing documentation..." >&2
    find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
    find /usr/share/doc -empty|xargs rmdir || true
    rm -rf /usr/share/man /usr/share/groff /usr/share/info /usr/share/lintian \
    /usr/share/linda /var/cache/man
fi

# Keep only the English translation
find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en' |xargs rm -r
