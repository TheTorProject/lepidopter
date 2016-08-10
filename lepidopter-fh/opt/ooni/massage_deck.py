#!/usr/bin/python

import os
import sys

import yaml

file_name = sys.argv[1]

try:
    if os.stat(file_name).st_size > 0:
        x = yaml.safe_load(open(file_name))
        print yaml.dump(filter(lambda k: "http_invalid_request_line" not in k
                                 ["options"]["test_file"], x))
    else:
        print "File %s is empty" % file_name
except IOError:
    print "Cannot open", file_name
