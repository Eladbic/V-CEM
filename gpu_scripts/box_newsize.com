#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to set the box files in EMAN1 format to a new size
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


        printf "${KBold}Despcription: ${KDefault}This program is used to set the box files in EMAN1 format to a new size.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <newsize> <box file1> [box file2] [...] \n"
        printf "${KBold}example:${KDefault} $Proc_name 120 data_1001.box \n"
        printf "${KBold}example:${KDefault} $Proc_name 120 data_1001.box data_1002.box\n"
        printf "${KBold}example:${KDefault} $Proc_name 120 data_1???.box\n"

        exit(1)
endif

set newsize=$argv[1]

set i=2

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .box`
set newbox=${root}_newsize.box
if ( -f ${root}.box) then
gawk '//{printf("%d\t%d\t%d\t%d\t%.3f\n",$1+ $3/2 - '$newsize'/2, $2 + $4/2 - '$newsize'/2 ,'$newsize','$newsize',$5)}' $box >  $newbox

echo "new size $newsize, from $argv[$i] to be  $newbox  "
else
echo "$box does not exists, or wrong format or suffix not .box"
endif

@ i++

end

exit
