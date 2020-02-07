#! /usr/bin/env python
#
# This file is part of the OpenMSX music set for OpenTTD.
# OpenMSX is free content; you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, version 2.
# OpenMSX is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details. You should have received a copy of
# the GNU General Public License along with Swedish RailSet. If not, see 
# <http://www.gnu.org/licenses/>.
#

import string
import sys
import subprocess
import os

while 1:
    data = sys.stdin.readline()
    if data != '':
        # leave out all comment lines (lines starting with '#')
        comment_pos = data.find('#')
        if comment_pos == 0:
            continue
        # separate the single entries by ';'
        separate = data.split(';')
        if len(separate) != 4:
            continue
        systemtype = (os.uname())[0]
        if systemtype == 'Linux':
            md5call = ["md5sum"]
        elif systemtype == 'Darwin':
            md5call = ["md5", "-r"]
        else:
            md5call = ["md5sum"]
        md5call = md5call + ["src/"+separate[1].strip()]
        md5sum = subprocess.Popen(md5call, stdout=subprocess.PIPE).communicate()[0]
        md5sum = md5sum.split()
        res = "%-32s = %s\n" % (separate[1], md5sum[0].decode())
        sys.stdout.write(res)
    else:
        sys.stdout.flush()
        break
