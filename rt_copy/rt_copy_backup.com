#!/bin/tcsh -f
#####************************************************************************************#####
#Description: This program is used to backup data from cryogpu computer to HDD.
#             run it from your /data/user
#	      set "backupDir" (the dir in backup HDD)  and "raw_mrc" (the origin dir ) to the right path.
#	      it will make the new dir if not exist. 
#	      
#             modify from:
#             http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/
#
#Author: Elad Binshtein 10312017
#####************************************************************************************#####
#Tips: 
#To stop it use this command 'touch ALL_STOP' 'touch all_stop'
#it will still finish the current micrograph and then stop before the next micrograph
#if you rerun the script on the same directory make sure to delete the "all_stop" file !!!!
#####************************************************************************************#####

set raw_mrc="/data/test_copy_rt/*mrcs" #the cryogpu dir
set backupDir="/run/media/binshtem/9ff3ae2d-f4c9-4649-b816-afbd033ed751/test_beckup_rt/" #the backup drive
if ( ! -d $backupDir ) then
   mkdir -p $backupDir
endif

##################################################################################################################
##############################   End of user input   #############################################################
##################################################################################################################

while ( 1 )

set allmrcf=`ls $raw_mrc`


foreach mrcf ($allmrcf)

if ( -f ALL_STOP || -f rcync_STOP || -f all_stop ) then
exit
endif

set root=`basename $mrcf .mrcs`

if ( -f ${root}_processing.log ) then
continue
else
echo "" > ${root}_processing.log
endif


if (  -f $backupDir${root}.mrcs &&  -s $backupDir${root}.mrcs &&  -Z $backupDir${root}.mrcs > 2278237820 && $backupDir$root.mrcs == $mrcf) then
#if the file already exists non-empty and full size, it will not do anything
echo "$mrcf already processed, automatically skipped."
continue


else
##### copy ####
echo "start in `date` to copy `du -h $mrcf`  to $backupDir .... "|tee -a copy.log
cp  $mrcf $backupDir$root.mrcs   
echo "finish in `date`"
endif


rm -f ${root}_processing.log

end

echo .+.+.+...+.+.+.+.+.+.+.+.+backup+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.
sleep 120s

end
#end while
