#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: 
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-6-24

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup

set args = ${#argv}
#set args = `printf "$argv" | wc | awk '{print $2}'`
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args < 3 || $1 == '--help' || $1 == '-h' ) then

        printf "${KBold}Despcription: ${KDefault}This program is used to generate a new star file in which the X,Y origins  are shifted to be 0,0 by compensation of the X,Y coordinates in the micrographs.\n"
        printf "              After that particles from each micrographs are then splited into individual files, so that you can use these files to re-extract the particles.\n"
        printf "              Then you can use the the new star file to extract particles again so that are particles should be well centered.\n"
        printf "              Make sure the star file contains _rlnImageName _rlnOriginX  _rlnOriginY   _rlnCoordinateX _rlnCoordinateY  columns at least.\n"

        printf "${KBold}Usage:${KDefault}   $Proc_name <star file1> <postfix> <micrographs 1> [micrographs 2] ... \n"
        printf "${KBold}example:${KDefault} $Proc_name  r3d2_cls1_data.star 0_F0-30_SumCorr.mrc Falcon_*_SumCorr.mrc \n"

        exit(1)
endif


set i=1



#######################################################################################
########################    centering coordinates       ###############################
#######################################################################################

set starf=$argv[$i]
set root=`basename $starf .star`
set starf_new=${root}_origin0.star

if ( -f ${root}.star) then
set rlnOriginXIndex=`gawk 'NR<50 && /_rlnOriginX/{print $2}' $starf  |cut -c 2- `
set rlnOriginYIndex=`gawk 'NR<50 && /_rlnOriginY/{print $2}' $starf |cut -c 2- `
set rlnCoordinateXIndex=`gawk 'NR<50 && /_rlnCoordinateX/{print $2}' $starf  |cut -c 2- `
set rlnCoordinateYIndex=`gawk 'NR<50 && /_rlnCoordinateY/{print $2}' $starf  |cut -c 2- `
set rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $starf  |cut -c 2- `

if ( $rlnImageNameIndex == "" || $rlnOriginXIndex == "" || $rlnOriginYIndex == "" || $rlnCoordinateXIndex == "" || $rlnCoordinateYIndex == "") then
echo "Make sure the star file contains _rlnImageName _rlnOriginX  _rlnOriginY   _rlnCoordinateX _rlnCoordinateY  columns."
exit
endif

#get line number of head of Relion star file
set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}' $starf `
gawk 'NR <= '$headN'' $starf > $starf_new

#gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/ && $'$rlnOriginXIndex'~/[0-9]/ && $'$rlnOriginYIndex'~/[0-9]/ { for(i=1;i<=NF;i++){ if( i=='$rlnCoordinateXIndex') printf("%d  ", 0.5 + ($i) - $'$rlnOriginXIndex' ); else if( i=='$rlnCoordinateYIndex') printf("%d  ", 0.5 + ($i) - $'$rlnOriginYIndex' );  else if( i=='$rlnOriginXIndex' || i=='$rlnOriginYIndex' ) printf("%f ",0 ); else    printf("%s  ", $i); }  printf("\n");}' $starf >>  $starf_new

gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/ && $'$rlnOriginXIndex'~/[0-9]/ && $'$rlnOriginYIndex'~/[0-9]/ { for(i=1;i<=NF;i++){ if( i=='$rlnCoordinateXIndex') printf("%d  ", 0.5 + ($i) - $'$rlnOriginXIndex' ); else if( i=='$rlnCoordinateYIndex') printf("%d  ", 0.5 + ($i) - $'$rlnOriginYIndex' );  else if( i=='$rlnOriginXIndex' || i=='$rlnOriginYIndex' ) printf("%f  ", $i - 1000 + int(1000 - $i +0.5) ); else    printf("%s  ", $i); }  printf("\n");}' $starf >>  $starf_new

#gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/ {printf("%d\t%d\t%d\t%f\n", ($'$rlnCoordinateXIndex')*'$shrink'  , ($'$rlnCoordinateYIndex' ) *'$shrink', $'$rlnClassNumberIndex' , $'$rlnAutopickFigureOfMeritIndex')}' $box >>  $starf

echo "transforming $argv[$i] to $starf_new "
else
echo "$starf does not exists, or wrong format or suffix not .star"
endif


#######################################################################################

set starf=${root}_origin0.star

set star_root=`basename  $starf .star`
if ( -f ${star_root}.star) then
#<<< stary if 1003

set rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $starf  |cut -c 2- `
set rlnMicrographNameIndex=`gawk 'NR<50 && /_rlnMicrographName/{print $2}' $starf  |cut -c 2- `

if ( $rlnImageNameIndex == "" && $rlnMicrographNameIndex == ""  ) then
echo "Make sure the star file contains  at least _rlnImageName or _rlnMicrographName  columns."
exit
endif

else
echo "$starf does not exists, or wrong format or suffix not .star"
exit
endif
#>>> end if 1003

#get line number of head of Relion star file
set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}' $starf `
gawk 'NR <= '$headN'' $starf > star_head$$.star

set postfix=`basename $2 .mrc`
set postfix=`basename $postfix .mrcs`

set i=3
while ($i <= $args )
#<<< star while 1000

set mrcf=$argv[$i]
set rootr=`basename $mrcf .mrc`
set root=`basename $rootr $postfix`
set starf_new=${root}${postfix}_split.star

if ( -f ${rootr}.mrc) then
#<<< start if 1001

gawk '/'$root'/' $starf > temp$$.star

if (-f temp$$.star  && -Z temp$$.star ) then
#<<< start if 1002
echo "spliting $starf to  $starf_new"
cp star_head$$.star   $starf_new
cat temp$$.star  >>  $starf_new
else
#<<< start if 1002
echo "No particles for $mrcf in star file $starf "

endif
rm -f temp$$.star

#>>> end if 1002

else
#<<<  if 1001

echo "$mrcf does not exists, or wrong format or suffix not .mrc"
endif
#>>> end if 1001

@ i++

end
#>>> end while 1000
rm -f star_head$$.star

      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"
