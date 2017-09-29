#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to shrink box files in EMAN1 format
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


        printf "${KBold}Despcription: ${KDefault}This program is used to shrink box files in EMAN1 format.\n"
        printf "              It's quite useful when you have box files in the original micrographs and want to use them in the shrinked micrographs.\n"
        printf "              In this case, the shrink factor is always larger than 1, for example 2, 3 or 4.\n"

        printf "${KBold}Usage:${KDefault}   $Proc_name <shrink factor> <box file1> [box file2] [...] \n"
        printf "${KBold}example:${KDefault} $Proc_name 2 data_1001.box \n"
        printf "${KBold}example:${KDefault} $Proc_name 4 data_1001.box data_1002.box\n"

        exit(1)
endif

set shrink=$argv[1]

set i=2

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .box`
set newbox=${root}_shrink${shrink}.box
if ( -f ${root}.box) then
gawk '//{printf("%d\t%d\t%d\t%d\t%.6f\t%d\n", $1/'$shrink' , $2 / '$shrink', $3 / '$shrink' , $4 / '$shrink', $5, $6)}' $box >  $newbox

echo "shrinking $argv[$i] to $newbox"
else
echo "$box does not exists, or wrong format or suffix not .box"
endif

@ i++

end

exit
