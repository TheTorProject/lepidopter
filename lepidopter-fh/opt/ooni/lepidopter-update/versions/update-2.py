"""
This is the auto update script for going from version 1 to version 2.
"""

import logging

from subprocess import check_call

__version__ = "2"

OONIPROBE_PIP_URL = "https://github.com/TheTorProject/ooni-probe/releases/download/v2.0.0-rc.3/ooniprobe-2.0.0rc3.tar.gz"

def _perform_update():
    check_call(["pip", "install", "--upgrade", OONIPROBE_PIP_URL])

def run():
    check_call(["systemctl", "stop", "ooniprobe"])
    try:
        _perform_update()
    except Exception as exc:
        logging.exception(exc)
        raise
    finally:
        check_call(["systemctl", "start", "ooniprobe"])

if __name__ == "__main__":
    run()
