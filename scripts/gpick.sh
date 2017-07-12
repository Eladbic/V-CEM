#!/bin/bash 

####################################################################
#
# *****YOU HAVE TO HAD GPU TO USE THIS SOFTWARE****
#
# this script will auto pick the particles [Gautomatch - Kai Zhang]
# if you give a template [T] it pick with it or make a default one if the is no template file
# will generate _automatch.star output file for Relion and _automatch.box
#
# change (i) first and last and VAR=file name path
# for help and tags type "Gautomatch-v0.53_sm_20_cu5.5_x86_64"
# 
#!!!!!!! befor run the script need to do:
#sbset cuda75
#
# Usage: gpick.sh > gpick.log
#
# Written by Elad Binshtein (060916)
############Variables############################################
VAR=sILSTAP_  #input file root
Gautomatch_DIR=/programs/x86_64-linux/gautomatch/0.53/bin/Gautomatch-v0.53_sm_20_cu7.5_x86_64
#/home/binshtem/bin/Gautomatch-v0.53_sm_20_cu5.5_x86_64
#################################################################

echo "Starting at `date`"   
for i in {3822..3822}
do
     
    $Gautomatch_DIR $VAR${i}_cor.mrc\
	--apixM 1.2466\
	--diameter 400 `#particle in angstrom`\
	--T 5averun6.mrcs`#template in .mrc`\
	--apixT 1.2466 `# template Apix`\
	--boxsize 380 `#in pixel`\
	--min_dist 350`#in angstrom`\
	--gid 0 `# GPU ID`
    
echo "finish $VAR${i} you'r the king  ~('_')~"
done
echo "Finish at `date`"

