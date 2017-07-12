#!/bin/bash

###################################################################
# this scrip is to convert dm4 files to mrcs stack (dm2mrc-imod)
# and motion corrected the mrcs projections (motioncorr2.1, Yifan Cheng)
# output file are corrected ave [filename_cor.mrc] and the corrected movie [filename_cor_movie.mrcs]
#
#Usage: motioncorr2_1.sh > log
#change (i) first and last and file name.
#-bin= binnig can be n=1,2
#-gpu= should be "0" if you have one GPU
#-fod= Suggest to set to TotalNumFrame/4
#
#!!!!!!! befor run the script need to:
#sbset cuda50
#sbset intel14
#
#
#Written by Elad Binshtein (11112015)
############Variables############################################
VAR=ILSTAP_  #input file root
motioncorr2_1=/home/binshtem/bin/dosefgpu_driftcorr
#################################################################


for i in {3007..3007}
do
    dm2mrc $VAR${i}.dm4 $VAR${i}.mrcs 
    if true
     then 
     echo "good job ^_^"
    fi 
    $motioncorr2_1 $VAR${i}.mrcs \
	-bin 2 \
	-ssc 1 \
	-gpu 1 \
	-fod 10 \
	-fcs $VAR${i}_cor.mrc \
	-fct $VAR${i}_cor_movie.mrcs || echo "mmmm... it still drifting"
    #rm -f  $VAR${i}.mrcs

echo finish_$VAR${i}
done
