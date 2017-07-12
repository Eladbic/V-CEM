#!/bin/bash

########################################
# to remane and remumbre you data set
# a=? will be the first new file # 
# printf "xxxx" will be the new name
#
# Elad Binshtein 120415
#######################################
a=2439
#for i in *.mrc; do
for i in ILSTAP_{2440..2605}.dm4; do
  new=$(printf "ILSTAP_%04d.dm4" ${a}) #04 pad to length of 4
  mv "${i}" "${new}"
  let a=a+1
done

