#! /usr/bin/env python

import string
import sys

res = ""
while 1:
    data = sys.stdin.readline()
    if data != '':
	# leave out all comment lines (lines starting with '#')
	comment_pos = string.find(data,'#')
	if comment_pos == 0:
		continue
	# separate the single entries by ';'
        separate = string.split(data,";")
	if len(separate) != 4:
		continue
	res = res + " src/" + string.strip(separate[1])
    else:
	sys.stdout.write(res)
        sys.stdout.flush()
        break
