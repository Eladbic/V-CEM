#!/bin/bash 

####################################################################
#
# *****YOU HAVE TO HAD GPU TO USE THIS SOFTWARE****
#
# this script will estimated the ctf parameter [Gctf - Kai Zhang]
# ctf is done on full micrograph and can by done localy (can be used for tilt) [--do_local_refine 1]
# will generate .star output file for Relion and _local.star if used with local_refine
#
# change VAR=file name path
# for help and tags type "Gctf-v0.50_sm_30_cu5.5_x86_64"
# 
#!!!!!!! befor run the script need to do:
#sbset cuda75
#
# Usage: gctf.sh > gctf.log
# run it outside the Micrographs/ directory to match Relion style
# Written by Elad Binshtein (060916)
############Variables############################################
VAR=Micrographs/*.mrc  #input file root
Gctf_DIR=/programs/x86_64-linux/gctf/0.50/bin/Gctf-v0.50_sm_30_cu7.5_x86_64
#/home/binshtem/bin/Gctf-v0.50_sm_30_cu5.5_x86_64
#################################################################

echo "Starting at `date`"   


     
    $Gctf_DIR $VAR\
	--apix 1.2466\
	--kv 300\
	--cs 2.2\
	--ac 0.1\
	--dstep 5.0\
	--resL 50\
	--resH 4\
	--do_EPA 1\
	--do_validation 1\
	--gid 0 `#GPU ID`\
	--logsuffix _ctffind3.log\
	--do_unfinished 1
#	--do_local_refine 1\
#	--boxsuffix _autopick.star\
#	--write_local_ctf 1
### if you want local_refine add "\" after "--do_unfinished 1" and uncomment the #
echo "finish $VAR${i} you'r CTF monster  ^('0')^"

echo "Finish at `date`"

