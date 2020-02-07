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

while 1:
    data = sys.stdin.readline()
    if data != '':
        # do some processing of the contents of
        # the data variable
        separate = data.split(';')
        print('%-30s %s' % (separate[1]+":", separate[2]))
        # end of data processing command group
        #        sys.stdout.write(res)
    else:
        sys.stdout.flush()
        break
