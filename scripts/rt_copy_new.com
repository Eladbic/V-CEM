#!/bin/tcsh -f
#####************************************************************************************#####
#Description: This program is used to copy data from K2 computer to cryogpu.
#             run it from your GPU/home and set "mydir" and "all_mrcfiles" to the right path.
#	      it will make the new dir if not exist.  
#             if you move .dm4 set "all_mrcfiles" to dm4
#             modify from:
#             http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/
#
#Author: Elad Binshtein
#####************************************************************************************#####



set all_mrcfiles="/raidx/Elad/caveolin1_061917/*mrc"
set mydir=/data/elad/projects/cav1/new/ #the cryogpu dir
if ( ! -d $mydir ) then
   mkdir -p $mydir
endif

#Tips: 
#To stop it use this command 'touch ALL_STOP'
#it will still finish the current micrograph and then stop before the next micrograph


##################################################################################################################
##############################   End of user input   #############################################################
##################################################################################################################

while ( 1 )

set allmrcf=`ls $all_mrcfiles`


foreach mrcf ($allmrcf)

if ( -f ALL_STOP || -f rcync_STOP ) then
exit
endif

set root=`basename $mrcf .mrc`

if ( -f ${root}_processing.log ) then
continue
else
echo "" > ${root}_processing.log
endif


if (  -f $mydir${root}.mrcs &&  -s $mydir${root}.mrcs &&  -Z $mydir${root}.mrcs > 2278237820 ) then
#if the file already exists non-empty and full size, it will not do anything
echo "$mrcf already processed, automatically skipped."
continue


else
##### copy ####
echo "start in `date` to copy `du -h $mrcf`  to $mydir .... "|tee copy.log
cp  $mrcf $mydir$root.tmp  #copy as temp file so other job like Relion2.0 wouldn't start until transfer is done 
mv $mydir$root.tmp $mydir$root.mrcs
echo "finish in `date`"
endif


rm -f ${root}_processing.log

end

echo ......................................................................
sleep 30s

end
#end while
