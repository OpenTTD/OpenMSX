#! /usr/bin/env python

import string
import sys

while 1:
    data = sys.stdin.readline()
    if data != '':
        # do some processing of the contents of
        # the data variable
        separate = string.split(data,";")
        print '%-30s %s' % (separate[1]+":", separate[2])
        # end of data processing command group
		#        sys.stdout.write(res)
    else:
        sys.stdout.flush()
        break
