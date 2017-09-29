#!/bin/csh -f
# generate a .doc file, contain the classes in order of decreasing number
#   of members

set ext = `ls avg001.* | awk -F "." '{printf("%s",$2)}'`

wc sel*.${ext} | sort -nr +0 | tail +2 | awk 'BEGIN {n=1} {printf(" %04d 2 %11.6f %11.6f\n", n++, substr($4, 4, 3), $1-1)}' > classorder.${ext}
