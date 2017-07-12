#!/bin/tcsh -f
#####************************************************************************************#####
#Description: This program is used to do real-time auto processing during data collection
#Copyright: MRC Laboratory of Molecular Biology
#Author: Kai Zhang
#Edit by Elad Binshtein 080116
#Now fited to start form .DM4 file format.
#The autopick step can be skiped by set the do_gautopick parameter to NO
#BUT then the Gctf 'GCTF_ExtraPar' need to change.
#the motioncorr is Agard motionCor2 !!!!!!!
#Tips: 
#To stop it use this command 'touch GCTF_STOP' or 'touch ALL_STOP'
#it will still finish the current micrograph and then stop before the next micrograph
#####************************************************************************************#####

#Requirement: imdo, dm2mrc; MotionCor2; Gctf; Gautomatch; Cuda libriary; High-end GPUs;  MRC\DM4 file format;

set all_mrcfiles = "*.dm4"           #####: new micrographs Dir
set convert_mrcs = "YES"                     #####: Yes or NO to convert DM4 to MRC format         


##### ----- MotionCor2 Parameters -----#####
set Motioncorr            = /home/binshtem/bin/MotionCor2-10-19-2016
set bin                   = 2                #####: can be 1 or 2
set Iter                  = 10               #####: Maximum iterations for iterative alignment
set Tol                   = 0.5              #####: Tolerance for iterative alignment
set Bft                   = 150              #####: 
set grid		  = "5 5"	     #####:Patch: the size of the grid for sub-frame alignment
set write_ali_stack       = "YES"            #####: Yes or NO [movie]
set Motioncorr_gid        = 0                #####: GPU id for Motioncorr, normally 0, and {0,1,2,3} for four GPUs
set Motincor_ExtraPar    = "-Kv 300 -PixSize 0.623 -FmDose 1.25 "  #####: parameter to do dose weighting all 3 needed for this. FmDose is the real dose.
#set Motincorr_ExtraPar1    = " -Gain FilePath -RotGain 0 -FlipGain 0 "  #####: parameter to applied gain refernce from file  0 - no rotation, default 1 - rotate 90 degree 2 - rotate 180 degree 3 - rotate 270 degree. flip gain reference after gain rotation. 0 - no flipping, default 1 - flip upside down 2 - flip left right.
set Motincorr_ExtraPar2    = "-Throw 0 -Trunc 0 "  #####: parameter to throw frame form the stack



##### -----  Gautomatch Parameters   -----#####
set GAUTOMATCH            = /programs/x86_64-linux/gautomatch/0.53/bin/Gautomatch-v0.53_sm_20_cu5.5_x86_64
set do_autopick           = "Yes"             #####: Yes or NO to do Gautopick
set apixM                 = 1.2466           #####: Micrograph pixel size in Angstrom (after Motioncorr)
set Templates             = NONE             #####: MRC stack; NULL or NONE to automatically generate templates
set apixT                 = 1.2466           #####: Templates pixel size in Angstrom;
set Diameter              = 400              #####: Diameter for estimation of local sigma, in Angstrom;
set min_dist              = 300              #####: Minimum distance between particles in angstrom; 0.9~1.1X diameter; can be 0.3~0.5 for filament-like particle;
set cc_cutoff             = 0.2              #####: Cross-correlation cutoff, 0.2~0.4 normally; Try to select several typical micrographs to optimize this value.
                                             #:     Alternatively, it will be even faster if you use a small value, e.g. 0.1, first and then use 'box_filter.com' or 'box_filter2rl.com' to filter the box files afterwards.
set lsigma_cutoff         = 1.3             #####:  Local sigma cutoff (relative value), 1.2~1.5 should be a good range; normally a value >1.2 will be ice, protein aggregation or contamination
set lsigma_Diamter        = 300             #####:  Diameter for estimation of local sigma, in angstrom

set lave_min              = -0.8            #####:  Local average cutoff (relative value), any pixel value below that will be considered as ice/aggregation/carbon etc.
set lave_max              = 1.2             #####:  Local average cutoff (relative value), any pixel value above that will be considered as ice/aggregation/carbon etc.
set lave_Diamter          = 480             #####:  Diameter for estimation of local average, in angstrom, 0.5~2.0X particle diameter suggested;
                                            #:      However, if you have 'sharp'/'small' ice or any 'dark'/'bright' dots, use a smaller value will be much better to get rid of these areas.

set lp                    = 30              #####:  Low-pass filter to increase the contrast of raw micrographs, suggested range 20~50Å. This low-pass is after ice/aggregation detection.
set hp                    = 1000            #####:  High-pass filter to get rid of the global background of raw micrographs, suggested range 200~2000Å. This high-pass is after ice/aggregation detection.
set GAUTOMATCH_gid        = 0               #####:  GPU id for Gautomatch, normally 0, and {0,1,2,3} for four GPUs 
set GAUTOMATCH_FOW        = "No"            #####:  Yes or NO, whether to force to overwrite the Gautomatch results?
                                            #####:  Normally, it will skip the files which have already been processed. If this is set Yes, it will overwrite the previous results(Not suggested)
set GAUTOMATCH_ExtraPar   = " --do_unfinished  --do_pre_filter --pre_hp 1000"    #####: the rest parameters if not set 
#set GAUTOMATCH_ExtraPar   = " --do_unfinished --exclusive_picking --excluded_suffix _rubbish.star"    #####: the rest parameters if not set 



##### -----      GCTF Parameters     -----#####
set GCTF                  = /programs/x86_64-linux/gctf/0.50/bin/Gctf-v0.50_sm_30_cu5.5_x86_64
set kV                    = 300              #####: High tension in Kilovolt, typically 300, 200 or 120
set Cs                    = 2.2              #####: Spherical aberration, in millimeter
set ac                    = 0.1              #####: Amplitude contrast
set GCTF_gid              = 0                #####: GPU id, normally 0, and {0,1,2,3} for four GPUs, can be different from Gautomatch
set GCTF_FOW              = "No"            #####:  Yes or NO, whether to force to overwrite the GCTF results? 
                                            #####:  Normally, it will skip the files which have already been processed. If this is set Yes, it will overwrite the previous results(Not suggested)
set GCTF_ExtraPar         = " --do_unfinished --do_local_refine --boxsuffix _automatch.star --dstep 5.0 --logsuffix _ctffind3.log"    #####: the rest parameters if not set 
#set GCTF_ExtraPar         = " --do_unfinished --dstep 5.0 --logsuffix _ctffind3.log"    #####: for use when NO Gautomatch are done!!! ####

#Tips: 
#To stop it use this command  'touch ALL_STOP' to stop automatic batch processing;
#it will still finish the current micrograph and then stop before the next micrograph


##################################################################################################################
##############################   End of user input   #############################################################
##################################################################################################################
#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"



#checking the settings:

if ( ! -f $Motioncorr ) then

echo "The program  $Motioncorr does NOT exisit! Exit now! "
exit 

else if ( ! -f $GAUTOMATCH ) then
echo "The program  $GAUTOMATCH does NOT exisit! Exit now! "
exit 

###### uncomment the below if you have a template for autopicking and specify the TEMPLATE.MRC file name in Gautomatch Parameters #######
#else if ( ! -f $Templates ) then						
#echo "The template $Templates does NOT exisit! Check your input! Exit now! "
#exit 

else if ( ! -f $GCTF ) then
echo "The program  $GCTF does NOT exisit! Exit now! "
exit 

endif


#end of global setup and chekcing ..................


while ( 1 )

set allmrcf=`ls $all_mrcfiles`

rm -f *_processing.log   */*_processing.log 

foreach mrcfus ($allmrcf)
#  foreach 999

#checking if movie exists
if ( ! -f $mrcfus ) then
echo "Warning: movie file $mrcfus does NOT exisit! Exit now!"
exit
endif

#whether to convert file format
set mrcf=`echo $mrcfus | sed  's/.dm4/.mrcs/g'`
if (  -f  ${mrcf} && -Z ${mrcf}  ) then
echo "dm2mrc on $mrcf already processed, automatically skipped. " 

else if ( $convert_mrcs =~ "Y*" ) then
dm2mrc $mrcfus $mrcf 
else
set mrcf=${mrcfus}
endif


### ===>>> get the root name of the micrograph(movies)
printf "${KBold} processing $mrcf .... $KDefault \n"

set root=`echo $mrcf | sed  's/.mrcs//g'`
set root=`echo $root | sed  's/.mrc//g'`
### ===>>> output controlling log, very useful to avoid the conflict of multiple jobs
if ( -f ${root}_processing.log ) then
continue
else
echo "" > ${root}_processing.log
endif

echo 
#######################################################################
############################ MOTIONCORR ###############################
#######################################################################
set OutStack=0
if ( $write_ali_stack == 1 || $write_ali_stack =~ 'Y*' ) then
set OutStack=1
endif

echo "running MotinCor2 on ${root}.mrcs ...."
echo "Output ${root}_SumCor.mrc ${root}_SumCor_Stk.mrc" 
echo

if (  -f  ${root}_SumCor.mrc && -Z ${root}_SumCor.mrc && $OutStack == 1  &&  -f ${root}_SumCor_Stk.mrc  &&  -Z ${root}_SumCor_Stk.mrc ) then
echo "MOTIONCORR on $mrcf already processed, automatically skipped. "
else if ( -f  ${root}_SumCor.mrc && -Z ${root}_SumCor.mrc && $OutStack == 0 ) then
echo "MOTIONCORR on $mrcf already processed, automatically skipped. "
else

echo "$Motioncorr -InMrc $mrcf -OutStack $OutStack -FtBin $bin -Iter $Iter -Tol $Tol -Bft $Bft -Patch $grid -Gpu $Motioncorr_gid -OutMrc ${root}_SumCor.mrc -LogFile ${root}.log $Motincor_ExtraPar $Motincorr_ExtraPar2"

$Motioncorr -InMrc $mrcf -OutStack $OutStack -FtBin $bin -Iter $Iter -Tol $Tol -Bft $Bft -Patch $grid -Gpu $Motioncorr_gid -OutMrc ${root}_SumCor.mrc -LogFile ${root}.log $Motincor_ExtraPar $Motincorr_ExtraPar2 | tee -a MOTIONCOR_auto_full.log

echo

endif
#endif Motioncorr

#######################################################################
########################### GAUTOMATCH ################################
#######################################################################

echo "running GAUTOMATCH on ${root}_SumCor.mrc .... " 
echo

if ( $do_autopick =~ "N*" ) then
echo "Skiping GAUTOMATCH you don't want to pick with me :( "
 
else if (  -f  ${root}_SumCor_automatch.star && $GAUTOMATCH_FOW =~ 'N*' && -Z ${root}_SumCor_automatch.star) then
#if the log file already exists and non-empty, it will not do anything
echo "GAUTOMATCH on ${root}_SumCor.mrc already processed, automatically skipped."

else

echo "$GAUTOMATCH  ${root}_SumCor.mrc --apixM $apixM     $GAUTOMATCH_ExtraPar  --T $Templates --apixT $apixT  --diameter $Diameter  --cc_cutoff  $cc_cutoff --min_dist $min_dist --lsigma_D $lsigma_Diamter --lsigma_cutoff $lsigma_cutoff   --lave_D $lave_Diamter   --lave_max  $lave_max  --lave_min $lave_min --lp $lp  --hp $hp --gid $GAUTOMATCH_gid $GAUTOMATCH_ExtraPar"

$GAUTOMATCH  ${root}_SumCor.mrc --apixM $apixM   $GAUTOMATCH_ExtraPar  --T $Templates --apixT $apixT  --diameter $Diameter  --cc_cutoff  $cc_cutoff --min_dist $min_dist --lsigma_D $lsigma_Diamter --lsigma_cutoff $lsigma_cutoff   --lave_D $lave_Diamter   --lave_max  $lave_max  --lave_min $lave_min --lp $lp  --hp $hp --gid $GAUTOMATCH_gid  $GAUTOMATCH_ExtraPar |tee -a GAUTOMATCH_auto_full.log

echo

endif
#endif Gautomatch


#######################################################################
############################## GCTF ###################################
#######################################################################


echo "running GCTF on ${root}_SumCor.mrc  .... " 
echo "${root}_SumCor.ctf "
echo
if (  -f  ${root}_SumCor.ctf &&  -Z ${root}_SumCor.ctf  && $GCTF_FOW =~ 'N*' ) then
#if the log file already exists and non-empty, it will not do anything
echo "GCTF on ${root}_SumCor.mrc already processed, automatically skipped."

else
##### Gctf ###
echo "$GCTF ${root}_SumCor.mrc  --apix $apixM  --cs $Cs --kV $kV --ac $ac --gid $GCTF_gid   $GCTF_ExtraPar"

$GCTF  ${root}_SumCor.mrc  --apix $apixM  --cs $Cs --kV $kV --ac $ac --gid $GCTF_gid   $GCTF_ExtraPar  |tee -a Gctf_auto_full.log 
endif

#endif GCTF


#######################################################################

rm -f ${root}_processing.log

if ( -f ALL_STOP ) then
exit
endif



echo "......................................................................\n"


#######################################################################
end 
# end foreach 999

printf "$KBold $KFlash ${KUnderline}======>>> ONE BIG CYCLE FINISHED, ANOTHER CYCLE ALL OVER AGAIN <<<====== ${KDefault}\n"
echo
echo   "#############################################################################################################"
printf "$KBold  REAL-TIME PROCESSING OF MOTION CORRECTION, PARTICLE PICKING, CTF DETERMINATION(CORRECTION) ${KDefault}\n"
echo   "#############################################################################################################"
echo 

sleep 5s

end
#end while


