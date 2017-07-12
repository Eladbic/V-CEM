#!/bin/bash

###################################################################
# this scrip convert .mrc stack to single .mrc files (newstack-imod)
# and renumber them with 4 dig.
# (it can convert any stack to single file).
#
# Written by Elad Binshtein (12122016)
############Variables############################################
in=protea.mrcs  #input file root
out=protea_	# output file name
ext=mrc		# output file name extension
first=1		# starting number for the single image
a=1		# renumber to 4 dig
###############################################################

echo "Starting at `date`"   

#for i in {4231..4432}
#do

newstack -sp $first -appe $ext  $in  $out

 if true
     then 
     echo "it good to be single ^_^"
    fi 


for i in $out*.mrc; do
#for i in ILSTAP_{2440..2605}.mrc; do
  new=$(printf "$out""%04d.mrc" ${a}) #04 pad to length of 4
  mv "${i}" "${new}"
  let a=a+1
done

echo "Finish at `date`"
