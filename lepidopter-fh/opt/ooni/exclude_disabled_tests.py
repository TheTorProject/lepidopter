#!/usr/bin/python
from __future__ import print_function

import os
import sys
import yaml
import tempfile

if len(sys.argv) != 2:
    print("Usage: %s [path_to_deck]" % (sys.argv[0]))
    sys.exit(1)

deck_filename = sys.argv[1]

disabled_tests = []

try:
    with open('/etc/ooniprobe/disabled-tests') as in_file:
        disabled_tests = map(lambda x: x.strip(), in_file.readlines())
except IOError:
    disabled_tests = ['http_invalid_request_line']

try:
    with open(deck_filename) as in_file:
        deck_data = yaml.safe_load(in_file)
except IOError:
    print("Failed to read file", file=sys.stderr)
    sys.exit(0)
except Exception:
    print("Other failure", file=sys.stderr)
    sys.exit(0)

tmp_file = tempfile.NamedTemporaryFile(delete=False)
try:
    filtered_deck_data = filter(lambda k: all(disabled_test not in k["options"]["test_file"]
                                for disabled_test in disabled_tests), deck_data)
    yaml.dump(filtered_deck_data, tmp_file)
    tmp_file.close()
    os.rename(tmp_file.name, deck_filename)
except Exception:
    print("Failed to clean up deck", file=sys.stderr)
    tmp_file.unlink(tmp_file.name)
    sys.exit(0)
