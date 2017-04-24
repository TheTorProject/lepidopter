"""
This is the auto update script for going from version 3 to version 4.
"""

import os
import logging

from datetime import datetime, timedelta

from subprocess import check_call

__version__ = "4"

OONIPROBE_PIP_URL = "ooniprobe==2.0.1"
OONI_LOG_PATH = "/var/log/ooni/"

past_2_days_ts = int((datetime.now() - timedelta(days=2)).strftime("%s"))

PUBLIC_KEY_PATH = "/opt/ooni/lepidopter-update/public.asc"
PUBLIC_KEY = """\
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: PGP

mQINBFfEAKABEADNBPp2nD48xXRhMdKMVXS2qHgDzokSAn3hikA+cb2IL5ssde0o
9HHzMxSNCbQBWo1bpmg84zsHvZTL+yEVGJ+o8DjLfdKKdMUOPsLTc0O1rqD0M6L4
35n6JjaeJp98HhVIRkmNqBG4pWMKLqvW1crEt5U8m/X7LWtTzsBt2DPi6UB6yDqw
520DLK051/0WKE+s7W8f8hYheHqyaUl35wtU6Qj7kjcDm0Kg57l7pY7gdYEeRizA
TECXy2c2mKJusql3p65FD/jNX6TncfHWiESvS8p31E8xx1hfgsgmh15JqrMTALm/
7cn3/IDV5vPBzi2pf4IlVHo34QcE26uj7QaXjrlQUkuds5cAFy/4uozN6J2PbH2x
e1+oI9rGxSf9m7UfAbudC+QATAlMDNeH2ngeqA0tm4vrMk/ybj5efeUjGNGNW0c8
6xfhbyhNJb6Rw2ScwdFUc/niWone3O1J3QkQ6CS6/gT3JCBMRVwLl+CkbeaALBTI
6We0CNQc1FXcWB84LI9F3UAHiR9jrmA3J/ck4R1oqv9STTrClTdWIvCK4sNa0sv7
ra1fdEV4CK1Z0qKxbKCk/JTlD/9w/OqZQqyJLOrWXomYxR6I6lxNwhoC+3Ysj5EG
Mmagpi+nnqAK0oIBkPytts9e6e1D54hS9sEG4uaEQRm229e0yhmQNQOKNwARAQAB
tDZPT05JIHNvZnR3YXJlIHVwZGF0ZSBrZXkgPGNvbnRhY3RAb3Blbm9ic2VydmF0
b3J5Lm9yZz6JAjcEEwEKACECGwMFCwkIBwMFFQoJCAsFFgIDAQACHgECF4AFAlil
vY4ACgkQw+zcBCBPnSkinhAAhlaPOq+X1rIcCbzePaf3/g47ha2AySPPVPL1hiiG
9b/YSemb5w9NTmPbsoJNQjQx9+4piLarSqN9Rihqw9T8IQ35EeuAd1sDBKseNbz6
nt54FwUb29o71S5nakDALflGTmHs0dx1vaG50weZ9HBvSw07KMNK01JNmAeZ5GgV
6B2UTa3yRoyTkBOcRVTxcn7JC0NdHpy+8OYpubDhPJPJJSMRqUaY05tfl8hLFMkh
7g6VQRa/nBiOHgfla9ZqHr7yrFWV0g8wKF8nVBGD+R4/qchBrh+ofPk+Y7Gm39gD
ux0mAX7xbJZpLry8BWBIUW50wlH1W4/Pq1kfw7m5vSQFCr0Ge8U/NQXkLwVf37Ow
TT6opY9pXCrVqV8Ris+gah7XJayVyiF+SpARn+e2EPHxxhVxpF8H9cArhmU+Z9Vx
PuLtGlCM5C0ypboHvEmqmSL2BhFhlxwchyqMf0h+6L5gR/i9GE+3QBFMewBQlgAf
7ioddEGIUdnsAeQJHByupycCDF9rVxzWiYgDffV8B6JXDuw9iCwhIrslOkRM6mHV
4/oe9PZ2Y+uLmcyOQa4Yk3jhr2aEa0r2Tuz1Jxw8DmY3y2GDNghuSHaKX++R4KqC
SYuU4/yn1F0nojEy4Q+RuLfV7Bu9BDSUtsPB1LgXWBtAA6gMK66UiExd6fNLhy94
1Dy5Ag0EV8QAoAEQAOQwsRo+2260kBYKnxRHr6rzTjStXtxsCsMUB08EXS7eTElw
DSE2C+pfeQjFe366f1zNTxY/CN6wCtd7wI4cVXWKLescFfCUrsg+S0Wfot85AXqC
qrPKFtKwW8khUeVnQfmHwhQl1W+/t+bE2p4X+0OR8qugHsMnvYwl+KpKsZ094Lwk
O8GRySB+LKm6KQtJ+WOnsvs3X8v8fSA6GwJjYdtKqNUzPBLpw8RrIH9leaT2pe9T
a48GqEwrU8wxwKyRBIfJJP/zq5n1rKcOBpvLZDVcyrVw+pIGa0zfmr/cqWYG7znx
2Xq3i22d36xPkfkZEyVnQcCJJ28hkAfXRYpp+gMnL0Zt4u3GgzSARSBSVrcMyNla
ft/aSOkojyjh3+2zF1PCfW1Nw9Sx50gdN3FfF0yEWjUoA1R/NW9CQZVG4qh/n2k5
08PYfZRuJ74T2jABFJIztv2pmq3VpSA7hkHGl3nXrdqpsw3V9bkFqZa/ihhY7IpG
wUWx4pDHh1gKhjJ0qPUVK5sOx3GZfEvMCCiH9XPk70fn3nuYupRr9WNrHJwUSeLM
hRvi4jTT+z5QLdYloFRZmDRwNg63csGZRkly9vjrAiMVHMpcJI0eCei/XgeKSxoi
AmzNuc2J47SF2z7WIsDwHhwRj6tj4dOW3Ye0WIkcTIvHd7UTVX02v+oBd5YhABEB
AAGJAh8EGAEKAAkCGwwFAlilvaIACgkQw+zcBCBPnSnQmA/9F9bt+Fd3SUz/bQRx
MDFpEmGJyT0okiCli6wPOHIGG/K7qUJrRGYIZiV6Wje92+G6YR7025D4qnJVLfBo
IB1HtA0PeP5Px8ICfYhMuBD+Z2CQFu03gq0gD8MLpCh6lsSOYc+g+uxyI2zmRVmC
CqH36GTf57xm9Kogc1kze9rEyUA9CR+gachWFrdhGXbyt6czop2oDDfJG/Pbllbu
b2+n8OebaQSElqd263sCFMfVXsXn1qjuBEOao4aC14MD8EnmxUjGknYQIxI0vgyS
a/UcGqJScsEW0LRz71O5HeyaJwGGsnFwZv3U75x3SKJvDNN+UugOAwCATAZ984c2
/R20d28WCLQYGOMxdRib9D5zlNrfjPVXKrXRkwxm5ucLhKrjgjp89uk+gyjZ1FnN
7V2YgJGMmL2jMsdGZpos7+MXpyoR0gTbtEaA9jWJlQNma1bAnEhnMaIZQGihyJs5
JOhkGuhuuVQqbRJ5xLBX9xOszmWUA4itqQoYWM3k43QKZl7MT4Oxqhhmvmv4hVh0
T8MdyzwACgAbLHsEMxb9kOMjhcIpRaP5ZzNWKIX8PPe92z4U6sqQGssBBaHAEPuN
FkpEG6zvsyimZlrp3Vz5m6FYbDZD0j63RiTPj4LupDLGqKGseyOYPvdZrmFTKWss
h+O+8iKVFs758eJDJtr72KlxfhQ=
=zx02
-----END PGP PUBLIC KEY BLOCK-----
"""
def write_signing_key():
    with open(PUBLIC_KEY_PATH, "w") as out_file:
        out_file.write(PUBLIC_KEY)

def _perform_update():
    # Deletes log files that are older than 2 days.
    # This is due to a problem in ooniprobe with logfiles ending up being too
    # large.
    for filename in os.listdir(OONI_LOG_PATH):
        filepath = os.path.join(OONI_LOG_PATH, filename)
        if os.path.getmtime(filepath) < past_2_days_ts:
            logging.info("Deleting %s" % filepath)
            os.unlink(filepath)

    # Update to the latest PGP signing key
    write_signing_key()

    # Fix pip bug introduced in setuptools v34.0.0
    # http://setuptools.readthedocs.io/en/latest/history.html#v34-0-0
    check_call(["apt-get", "-q", "update"])
    check_call(["apt-get", "-y", "install", "-t", "stretch", "python-pip"])
    # Remove previously installed python packages
    check_call(["apt-get", "-y", "autoremove"])
    check_call(["pip", "install", "setuptools==34.2.0"])

    check_call(["pip", "install", "--upgrade", OONIPROBE_PIP_URL])

def run():
    try:
        check_call(["systemctl", "stop", "ooniprobe"])
    except Exception as exc:
        logging.error("Failed to stop ooniprobe-agent")
        logging.exception(exc)
    try:
        _perform_update()
    except Exception as exc:
        logging.exception(exc)
        raise
    finally:
        try:
            check_call(["systemctl", "start", "ooniprobe"])
        except Exception as exc:
            logging.error("Failed to start ooniprobe-agent")
            logging.exception(exc)

if __name__ == "__main__":
    run()
