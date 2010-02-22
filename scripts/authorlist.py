#! /usr/bin/env python

import string
import sys

while 1:
    data = sys.stdin.readline()
    if data != '':
        # do some processing of the contents of
        # the data variable
        separate = string.split(data,";")
	res = separate[1] + ": \t" + separate[2] + "\n"
        # end of data processing command group
        sys.stdout.write(res)
    else:
        sys.stdout.flush()
        break