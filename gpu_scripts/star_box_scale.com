#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to scale star box files in Relion format
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-3-29

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup

set args = `printf "$argv" | wc | awk '{print $2}'`
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args <= 1 || $1 == '--help' || $1 == '-h' ) then


        printf "${KBold}Despcription: ${KDefault}This program is used to scale star box files in Relion format.\n"
        printf "              It's quite useful when you pick your particles in the shrinked(binned) micrographs and then use the box files for the original micrographs.\n"
        printf "              In this case, the scaling factor is always larger than 1, for example 2, 3 or 4.\n"
        printf "              Also, you can scale the original box files to the shrinked files, egg 2 or 3 or 4 tiems.\n"
        printf "              In this case, the scaling factor is smaller than 1, egg. 0.5, 0.333, 0.25... for 2, 3 or 4 tiems shrinking.\n"
        printf "              Make sure the box file contains  _rlnCoordinateX _rlnCoordinateY   columns.\n"

        printf "${KBold}Usage:${KDefault}   $Proc_name <scale factor> <box file1> [box file2] [...] \n"
        printf "${KBold}example:${KDefault} $Proc_name 2 data_1001_manualpick.star \n"
        printf "${KBold}example:${KDefault} $Proc_name 4 data_1001_manualpick.star data_1002_manualpick.star\n"
        printf "${KBold}example:${KDefault} $Proc_name 0.5 data_1???_manualpick.star\n"

        exit(1)
endif

set scale=$argv[1]

set i=2

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .star`
set starf=${root}_scale${scale}.star

if ( -f ${root}.star) then
set rlnCoordinateXIndex=`gawk 'NR<50 && /_rlnCoordinateX/{print $2}' $box |cut -c 2- `
set rlnCoordinateYIndex=`gawk 'NR<50 && /_rlnCoordinateY/{print $2}' $box |cut -c 2- `

if ( $rlnCoordinateXIndex == "" || $rlnCoordinateYIndex == "") then

echo "Make sure the box file contains  _rlnCoordinateX _rlnCoordinateY   columns."
exit

endif

#get line number of head of Relion star file
set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}' $box `
gawk 'NR <= '$headN'' $box > $starf

gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/ { for(i=1;i<=NF;i++){ if( i=='$rlnCoordinateXIndex' ||  i=='$rlnCoordinateYIndex') printf("%f\t", ($i)*'$scale'); else   printf("%s\t", $i); }  printf("\n");}' $box >>  $starf

#gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/ {printf("%d\t%d\t%d\t%f\n", ($'$rlnCoordinateXIndex')*'$scale'  , ($'$rlnCoordinateYIndex' ) *'$scale', $'$rlnClassNumberIndex' , $'$rlnAutopickFigureOfMeritIndex')}' $box >>  $starf

echo "scaling $argv[$i] to $starf "
else
echo "$box does not exists, or wrong format or suffix not .star"
endif

@ i++

end

exit
