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

    check_call(["pip", "install", "--upgrade", OONIPROBE_PIP_URL])

    # Set it as already initialized so we skip the informed consent on
    # pre-existing ooniprobes.
    with open("/var/lib/ooni/initialized", "w"):
        pass

    check_call(["systemctl", "enable", "ooniprobe"])
    check_call(["systemctl", "start", "ooniprobe"])

def run():
    try:
        _perform_update()
    except Exception as exc:
        logging.exception(exc)
        raise

if __name__ == "__main__":
    run()
