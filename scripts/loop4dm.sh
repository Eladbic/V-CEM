#!/bin/bash

###################################################################
# this scrip is to convert dm4 files to mrcs stack (dm2mrc-imod) 
#
#Usage: loop4dm.sh 
#change (i) first and last and file name.
#Written by Elad Binshtein (01052016)
############Variables############################################
VAR=ILSTAP_  #input file root

#################################################################

echo "Starting at `date`"   
for i in {1679..1750}
do 
    dm2mrc $VAR${i}.dm4 $VAR${i}.mrcs 
    if true
     then 
     echo "good job ^_^"
    fi 
    cp $VAR${i}.mrcs /hd0/Spliceosome/ILS/Raw_micrographs/11_121615_Cdc5TAP
    echo "copy $VAR${i}.mrcs"
#    rm -f  $VAR${i}.dm4 ## make sure you know what you delet !!!!
done
echo "Finish at `date`"
