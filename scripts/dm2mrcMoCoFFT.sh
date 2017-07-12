#!/bin/bash

###################################################################
# this scrip is to convert dm4 files to mrcs stack (dm2mrc-imod)
# clip to square and  bined it in the FFT space. (e2proc2d.py - EMAN)
# and motion corrected the mrcs projections (motioncorr, Yifan Cheng)
# output file are corrected ave [filename_Cor.mrc] and the corrected movie [filename_Cor_movie.mrcs]
#
#Usage: dm2mrcMoCoFFT.sh > log
#change (i) first and last and file name.
#clip to 7424x7424 (7420x7420) if superres or 3712x3712 (3710x3710) if not.
#binnig can be n=2,4,8...
#if you have odd/even number file (dm4 stack) use the if-fi loop at the end by delette the #
#
#!!!!!!! befor run the script need to:
#sbset cuda50
#sbset intel14
#
#
#Written by Elad Binshtein (11112015)
############Variables############################################
VAR=ILSTAP_  #input file root
#################################################################


for i in {0001..0002}
do
    dm2mrc $VAR${i}.dm4 $VAR${i}.mrcs 
    if true
     then 
     echo "good job ^_^"
    fi 
    e2proc2d.py $VAR${i}.mrcs s$VAR${i}.mrcs --clip=7420,7420  --process math.fft.resample:n=2
    if [ "$?" = "0" ]
     then
     rm -f $VAR${i}.mrcs
     echo "you'r a shrinker...."
    else
     echo "can't binned )-:"
     exit 1
    fi
 #   if [ $((10#$i%2)) -eq 1 ]
 #    then
    /home/binshtem/bin/motioncorr s$VAR${i}.mrcs -ssc 1 -fcs s$VAR${i}_Cor.mrc -fct s$VAR${i}_Cor_movie.mrcs || echo "mmmm... it still drifting"
    rm -f  s$VAR${i}.mrcs
 #   fi
echo finish_$VAR${i}
done
