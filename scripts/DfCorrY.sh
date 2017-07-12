#!/bin/bash

###################################################################
# this scrip is to convert dm4 files to mrcs stack (dm2mrc-imod)
# and motion corrected the mrcs projections (MotionCor2, D. Agard)
# output file are corrected sum [sfilename_cor.mrc]
# and corrected movie
#
#Usage: DfCorrY.sh > motion.log
#change  (VAR) your input and (i) first and last and file name.
#for help and tags type "MotionCor2-10-19-2016"
# for now it's: bin by 2, 5x5 patch, dose weighting 1.25 e/A^2/frame
# the Fmdose should be your experimental dose
#
#!!!!!!! befor run the script need to do:
#sbset cuda50 or higher
#sbset intel14
#
#
#Written by Elad Binshtein (01052016)
############Variables############################################
VAR=ILSTAP_  #input file root
MotionCor2_DIR=/home/binshtem/bin/MotionCor2-10-19-2016
#################################################################

echo "Starting at `date`"   
for i in {4231..4432}
do
    dm2mrc $VAR${i}.dm4 $VAR${i}.mrcs 

   if true
     then 
     echo "good job ^_^"
    fi 
    $MotionCor2_DIR \
-InMrc $VAR${i}.mrcs \
-OutMrc s$VAR${i}_cor.mrc \
-Patch 5 5 \
-Iter 10 \
-Tol 0.5 \
-Bft 100 \
-Kv 300 \
-PixSize 0.623 \
-FmDose 1.25 \
-LogFile s$VAR${i} \
-FtBin 2 \
-Gpu 0 
#-Throw \
#-Trunc \
#-OutStack 1 
 echo "mmmm... it still drifting"
### if you want to throw initial number of frames uncomment "-Throw" above 
### if you want to truncate last number of frames uncomment "-Trunc" above
### if you want align movie uncomment "-OutStack" above

    rm -f  $VAR${i}.dm4 ## make sure you know what you delet !!!!
echo finish_$VAR${i} "you'r the king  ~('_')~"
done
echo "Finish at `date`"
