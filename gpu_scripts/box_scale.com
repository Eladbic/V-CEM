#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to scale box files in EMAN1 format
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


        printf "${KBold}Despcription: ${KDefault}This program is used to scale box files in EMAN1 format.\n"
        printf "              It's quite useful when you pick your particles in the shrinked(binned) micrographs and then use the box files for the original micrographs.\n"
        printf "              In this case, the scaling factor is always larger than 1, for example 2, 3 or 4.\n"

        printf "              Also, you can scale the original box files to the shrinked files, egg 2 or 3 or 4 tiems.\n"
        printf "              In this case, the scaling factor is smaller than 1, egg. 0.5, 0.333, 0.25... for 2, 3 or 4 tiems shrinking.\n"

        printf "${KBold}Usage:${KDefault}   $Proc_name <scale factor> <box file1> [box file2] [...] \n"
        printf "${KBold}example:${KDefault} $Proc_name 2 data_1001.box \n"
        printf "${KBold}example:${KDefault} $Proc_name 4 data_1001.box data_1002.box\n"
        printf "${KBold}example:${KDefault} $Proc_name 0.5 data_1???.box\n"

        exit(1)
endif

set scale=$argv[1]

set i=2

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .box`
set newbox=${root}_scale${scale}.box
if ( -f ${root}.box) then
gawk '//{printf("%d\t%d\t%d\t%d\t%.3f\n",'$scale' * $1, '$scale' * $2,'$scale' * $3, '$scale' * $4, $5)}' $box >  $newbox

echo $argv[$i]
else
echo "$box does not exists, or wrong format or suffix not .box"
endif

@ i++

end

exit
