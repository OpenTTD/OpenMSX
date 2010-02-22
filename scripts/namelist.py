#! /usr/bin/env python

import string
import sys

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
	res = separate[1] + "\t= " + string.strip(separate[3]) + "\n"
        sys.stdout.write(res)
    else:
        sys.stdout.flush()
        break

def authorlist(mystr):
	separate = string.split()
	for str in separate:
		print string.strip(str)