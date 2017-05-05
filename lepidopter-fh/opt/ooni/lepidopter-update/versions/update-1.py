"""
This is the auto update script for going from version 0 to version 1.

All future lepidopter will start with version 1 already configured, so this should
not be run by them.

In order to indicate that they are configured with version 1 a file called
/etc/lepidopter-update/version with the string 1.

When this is run it will configure the pi to be already initialized and this
should not happen in future versions of lepidopter.
"""

import os
import shutil
import logging

from subprocess import check_call

__version__ = "1"

OONIPROBE_PIP_URL = "https://github.com/TheTorProject/ooni-probe/releases/download/v2.0.0-rc.2/ooniprobe-2.0.0rc2.tar.gz"

OONIPROBE_SYSTEMD_SCRIPT = """\
[Unit]
Description=%n, network interference detection tool
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/lib/ooni/twistd.pid
ExecStart=/usr/local/bin/ooniprobe-agent start
ExecStop=/usr/local/bin/ooniprobe-agent stop
TimeoutStartSec=300
TimeoutStopSec=60
Restart=on-failure

[Install]
WantedBy=multi-user.target
"""
OONIPROBE_SYSTEMD_PATH = "/etc/systemd/system/ooniprobe.service"

OONIPROBE_CONFIG = """
basic:
   logfile: /var/log/ooni/ooniprobe.log
advanced:
   webui_port: 80
   webui_address: "0.0.0.0"
tor:
    data_dir: /opt/ooni/tor_data_dir
"""
OONIPROBE_CONFIG_PATH = "/etc/ooniprobe.conf"

DEFAULT_RCS = """\
#
# /etc/default/rcS
#
# Default settings for the scripts in /etc/rcS.d/
#
# For information about these variables see the rcS(5) manual page.
#
# This file belongs to the "initscripts" package.

# delete files in /tmp during boot older than x days.
# '0' means always, -1 or 'infinite' disables the feature
#TMPTIME=0

# spawn sulogin during boot, continue normal boot if not used in 30 seconds
#SULOGIN=no

# do not allow users to log in until the boot has completed
#DELAYLOGIN=no

# be more verbose during the boot process
#VERBOSE=no

# automatically repair filesystems with inconsistencies during boot
FSCKFIX=yes
"""
DEFAULT_RCS_PATH = "/etc/default/rcS"

DEFAULT_HWCLOCK = """\
# Defaults for the hwclock init script.  See hwclock(5) and hwclock(8).

# This is used to specify that the hardware clock incapable of storing
# years outside the range of 1994-1999.  Set to yes if the hardware is
# broken or no if working correctly.
#BADYEAR=no

# Set this to yes if it is possible to access the hardware clock,
# or no if it is not.
HWCLOCKACCESS=no

# Set this to any options you might need to give to hwclock, such
# as machine hardware clock type for Alphas.
#HWCLOCKPARS=

# Set this to the hardware clock device you want to use, it should
# probably match the CONFIG_RTC_HCTOSYS_DEVICE kernel config option.
#HCTOSYS_DEVICE=rtc0
"""
DEFAULT_HWCLOCK_PATH = "/etc/default/hwclock"

CRONTAB = """\
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user	command
17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
17 4	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
"""
CRONTAB_PATH = "/etc/crontab"

AVAHI_OONIPROBE = """\
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">ooniprobe GUI on %h</name>
  <service>
     <type>_http._tcp</type>
     <port>80</port>
  </service>
</service-group>
"""
AVAHI_OONIPROBE_PATH = "/etc/avahi/services/ooniprobe.service"

AVAHI_SSH = """\
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">SSH on %h</name>
  <service>
     <type>_ssh._tcp</type>
     <port>22</port>
  </service>
</service-group>
"""
AVAHI_SSH_PATH = "/etc/avahi/services/ssh.service"

LEPIDOPTER_UPDATE_LOGROTATE = """\
/var/log/ooni/lepidopter-update.log {
    missingok
    rotate 2
    copytruncate
    maxsize 1M
    notifempty
}
"""
LEPIDOPTER_UPDATE_LOGROTATE_PATH = "/etc/logrotate.d/lepidopter-update"

OONIPROBE_CRONJOBS_LOGROTATE = """\
/var/log/ooni/cronjobs.log {
    missingok
    rotate 1
    compress
    delaycompress
    copytruncate
    maxsize 1M
    notifempty
}
"""
OONIPROBE_CRONJOBS_LOGROTATE  = "/etc/logrotate.d/ooniprobe"

PUBLIC_KEY_PATH = "/opt/ooni/lepidopter-update/public.asc"
PUBLIC_KEY = """\
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: PGP

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
h+O+8iKVFs758eJDJtr72KlxfhQ=
=zx02
-----END PGP PUBLIC KEY BLOCK-----
"""


def rm_rf(path):
    if os.path.isdir(path):
        shutil.rmtree(path, ignore_errors=True)
    elif os.path.isfile(path):
        os.remove(path)

def write_systemd_script():
    if os.path.exists(OONIPROBE_SYSTEMD_PATH):
        check_call(["service", "ooniprobe", "stop"])

    with open(OONIPROBE_SYSTEMD_PATH, "w") as out_file:
        out_file.write(OONIPROBE_SYSTEMD_SCRIPT)

def write_ooniprobe_config():
    with open(OONIPROBE_CONFIG_PATH, "w") as out_file:
        out_file.write(OONIPROBE_CONFIG)

def write_default_rcs():
    with open(DEFAULT_RCS_PATH, "w") as out_file:
        out_file.write(DEFAULT_RCS)

def write_default_hwclock():
    with open(DEFAULT_HWCLOCK_PATH, "w") as out_file:
        out_file.write(DEFAULT_HWCLOCK)

def write_crontab():
    with open(CRONTAB_PATH, "w") as out_file:
        out_file.write(CRONTAB)

def write_avahi_ooniprobe():
    with open(AVAHI_OONIPROBE_PATH, "w") as out_file:
        out_file.write(AVAHI_OONIPROBE)

def write_avahi_ssh():
    with open(AVAHI_SSH_PATH, "w") as out_file:
        out_file.write(AVAHI_SSH)

def write_lepidopter_update_logrotate():
    with open(LEPIDOPTER_UPDATE_LOGROTATE_PATH, "w") as out_file:
        out_file.write(LEPIDOPTER_UPDATE_LOGROTATE)

def write_cronjobs_logrotate():
    with open(OONIPROBE_CRONJOBS_LOGROTATE , "w") as out_file:
        out_file.write(OONIPROBE_CRONJOBS_LOGROTATE )

def write_signing_key():
    with open(PUBLIC_KEY_PATH, "w") as out_file:
        out_file.write(PUBLIC_KEY)

def _perform_update():
    # Delete all the daily crons
    rm_rf("/etc/cron.daily/remove_upl_reports")
    rm_rf("/etc/cron.daily/run_ooniprobe_deck")
    rm_rf("/etc/cron.daily/upload_reports")

    # Delete all the weekly crons
    rm_rf("/etc/cron.weekly/remove_inc_reports")
    rm_rf("/etc/cron.weekly/update_ooniprobe_deck")

    # Remove unneeded cronjobs
    rm_rf("/etc/cron.daily/apt")
    rm_rf("/etc/cron.daily/dpkg")
    rm_rf("/etc/cron.daily/man-db")
    rm_rf("/etc/cron.daily/tor")
    rm_rf("/etc/cron.daily/update_ooniprobe")

    rm_rf("/etc/ooniprobe/ooniprobe.conf")
    rm_rf("/etc/ooniprobe/oonireport.conf")
    rm_rf("/etc/ooniprobe/oonideckconfig")

    rm_rf("/opt/ooni/remove-inc-reports.sh")
    rm_rf("/opt/ooni/remove-upl-reports.sh")
    rm_rf("/opt/ooni/run-ooniprobe.sh")
    rm_rf("/opt/ooni/update-deck.sh")
    rm_rf("/opt/ooni/upload-reports.sh")

    rm_rf("/opt/ooni/update-ooniprobe.sh")

    # Remove unused folders
    # New PATH: /var/lib/ooni/decks-enabled
    rm_rf("/opt/ooni/decks")
    # New PATH: /var/lib/ooni/measurements
    rm_rf("/opt/ooni/reports")

    check_call(["apt-get", "update"])
    # Do not access hwclock Raspberry Pi doesn't have one, use fake-hwclock
    # Add Avahi mDNS/DNS-SD daemon
    # Add wireless network interface specific package dependencies
    check_call(("apt-get -y install fake-hwclock avahi-daemon wireless-tools "
               "wpasupplicant wireless-regdb crda").split(" "))

    write_default_rcs()
    write_default_hwclock()
    write_crontab()

    write_systemd_script()

    write_lepidopter_update_logrotate()
    write_cronjobs_logrotate()

    write_ooniprobe_config()

    write_avahi_ooniprobe()
    write_avahi_ssh()

    shutil.copyfile("/usr/share/zoneinfo/UTC", "/etc/localtime")

    # Update to the latest PGP signing key
    write_signing_key()

    # Fix pip bug introduced in setuptools v34.0.0
    # http://setuptools.readthedocs.io/en/latest/history.html#v34-0-0
    check_call(["apt-get", "-y", "install", "-t", "stretch", "python-pip"])
    # Remove previously installed python packages
    check_call(["apt-get", "-y", "autoremove"])
    check_call(["pip", "install", "setuptools==34.2.0"])

    check_call(["pip", "install", "--upgrade", OONIPROBE_PIP_URL])

    # Set it as already initialized so we skip the informed consent on
    # pre-existing ooniprobes.
    with open("/var/lib/ooni/initialized", "w"):
        pass

    check_call(["systemctl", "enable", "ooniprobe"])
    try:
        check_call(["systemctl", "start", "ooniprobe"])
    except Exception as exc:
        logging.error("Failed to start ooniprobe agent")
        logging.exception(exc)

def run():
    try:
        _perform_update()
    except Exception as exc:
        logging.exception(exc)
        raise

if __name__ == "__main__":
    run()
