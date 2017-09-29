#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to change some parameters of a star file so that it can be used for the shrinked particels.
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

set args = `printf "$argv" | wc | awk '{print $2}'`
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args < 1 || $1 == '--help' || $1 == '-h' ) then

        printf "${KBold}Despcription: ${KDefault}This program is used to change some parameters of a star file so that the shrinked particels will go back to the original ones.\n"
        printf "              The columns that will be modified include  _rlnOriginX _rlnOriginY _rlnDetectorPixelSize and _rlnImageName.\n"
        printf "              Make sure the star file contains at least _rlnDetectorPixelSize and _rlnImageName columns.\n"
        printf "              If the star files do not contain _rlnOriginX or _rlnOriginY, it will just ignore these column, but if the files contain these two, they will be shrinked as well.\n"
        printf "              Unlike star_box_shrink.com, this program will not modify _rlnCoordinateX or _rlnCoordinateY. So when you go back to the original star file, you just reset the _rlnOriginX _rlnOriginY _rlnDetectorPixelSize and _rlnImageName columns.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <shrink factor> <star file1> <star file2> ...\n"
        printf "${KBold}example:${KDefault} $Proc_name 4 r3d2_cls2_data_shrink4.star  \n"
        printf "${KBold}example:${KDefault} $Proc_name 2 r3d2_cls*_data_shrink2.star  \n"

        exit(1)
endif


set shrink=$1

set i=2

while ($i <= $args )
#<<< star while 1000

set starf=$argv[$i]
set root=`basename $starf .star`
set starf_new=${root}_expand${shrink}.star

if ( -f ${root}.star) then
set rlnOriginXIndex=`gawk 'NR<50 && /_rlnOriginX/{print $2}' $starf  |cut -c 2- `
set rlnOriginYIndex=`gawk 'NR<50 && /_rlnOriginY/{print $2}' $starf |cut -c 2- `
set rlnDetectorPixelSizeIndex=`gawk 'NR<50 && /_rlnDetectorPixelSize/{print $2}' $starf  |cut -c 2- `
set rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $starf  |cut -c 2- `
set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}' $starf `
gawk 'NR <= '$headN'' $starf > $starf_new

if ( $rlnDetectorPixelSizeIndex == "" || $rlnImageNameIndex == "") then
echo "Make sure the star file contains at least _rlnDetectorPixelSize and _rlnImageName  columns."
rm -f $starf_new
exit

else if ( ( ! ($rlnDetectorPixelSizeIndex == "" || $rlnImageNameIndex == "") ) &&  ( $rlnOriginXIndex == "" || $rlnOriginYIndex == "" )  ) then
#get line number of head of Relion star file

gawk '$'$rlnDetectorPixelSizeIndex'~/[0-9]/ { for(i=1;i<=NF;i++){if (i=='$rlnDetectorPixelSizeIndex') printf("%f  ",$i / '$shrink' ) ;else if (i=='$rlnImageNameIndex') printf("%s.mrcs  ",substr($i,0,length($i)-13) );  else    printf("%s  ", $i); }  printf("\n");}' $starf >>  $starf_new

else if ( ( ! ($rlnDetectorPixelSizeIndex == "" || $rlnImageNameIndex == "") ) && ( ! ( $rlnOriginXIndex == "" || $rlnOriginYIndex == "") ) ) then

gawk '$'$rlnOriginXIndex'~/[0-9]/ && $'$rlnOriginYIndex'~/[0-9]/ && $'$rlnDetectorPixelSizeIndex'~/[0-9]/ { for(i=1;i<=NF;i++){ if( i=='$rlnOriginXIndex' || i=='$rlnOriginYIndex' ) printf("%f  ",$i * '$shrink' ); else if (i=='$rlnDetectorPixelSizeIndex') printf("%f  ",$i / '$shrink' ) ;else if (i=='$rlnImageNameIndex') printf("%s.mrcs  ",substr($i,0,length($i)-13) );  else    printf("%s  ", $i); }  printf("\n");}' $starf >>  $starf_new

endif



echo "transforming $argv[$i] to $starf_new "
else
echo "$starf does not exists, or wrong format or suffix not .star"
endif

@ i++

end
#>>> end while 1000


      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

