#!/bin/tcsh -f
#####************************************************************************************#####
#Description: This program is used to do automatic CTF determination during data collection
#             It is originally used for real-time CTF determination, but not only limited to that.
#             You can easily modified the script to replace Gctf for any other purpose.
#             But do acknowledge the link for this script:
#             http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/
#Copyright: MRC Laboratory of Molecular Biology
#Author: Kai Zhang
#####************************************************************************************#####



set all_mrcfiles="*mrc"
set Gprogram=Gctf
set Gprogram_parameters="--apix 1  --kV 300 --Cs 2.7 --ac 0.1 "

#Tips: 
#To stop it use this command 'touch GCTF_STOP' or 'touch ALL_STOP'
#it will still finish the current micrograph and then stop before the next micrograph


##################################################################################################################
##############################   End of user input   #############################################################
##################################################################################################################

while ( 1 )

set allmrcf=`ls $all_mrcfiles`


foreach mrcf ($allmrcf)

if ( -f ALL_STOP || -f GCTF_STOP ) then
exit
endif

set root=`basename $mrcf .mrc`

if ( -f ${root}_processing.log ) then
continue
else
echo "" > ${root}_processing.log
endif


echo "$mrcf .... " 
if (  -f  ${root}.ctf &&  -Z ${root}.ctf  ) then
#if the log file already exists and non-empty, it will not do anything
echo "$mrcf already processed, automatically skipped."

else
##### Gctf ###
$Gprogram  $Gprogram_parameters  $mrcf  |tee Gctf_auto_full.log
endif


rm -f ${root}_processing.log

end

echo ......................................................................
sleep 3s

end
#end while
