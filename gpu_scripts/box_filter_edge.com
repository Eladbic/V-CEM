#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to filter out all particles from certain distance to the edges;
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

if ( $args <= 3 || $1 == '--help' || $1 == '-h' ) then


        printf "${KBold}Despcription: ${KDefault}This program is used to filter out all particles from certain distance(in pixel) to the edges.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <Nx> <Ny> <distance> <box file1> [box file2] [...] \n"
        printf "         Nx, Ny: Micrograph X and Y sizes; distance: the cutoff for particles filtering, should be around 1/2 of the particle boxsize\n"
        printf "${KBold}example:${KDefault} $Proc_name 4096  4096   120  mic_1001.box \n"
        printf "${KBold}example:${KDefault} $Proc_name 3788  3712   360  mic_1001.box mic_1002.box\n"
        printf "${KBold}example:${KDefault} $Proc_name 4096  4096   400  mic_1???.box\n"

        exit(1)
endif

set Nx=$argv[1]
set Ny=$argv[2]
set distance=$argv[3]

set i=4

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .box`
set newbox=${root}_filter.box
if ( -f ${root}.box) then
gawk '//{if( ($1+ $3/2 - '$distance' >= 0) && ($2+ $4/2 - '$distance' >= 0) && ($1+ $3/2 + '$distance' <= '$Nx') && ($2+ $4/2 + '$distance' <= '$Ny')  )printf("%s\n",$0)}' $box >  $newbox

echo "filtering particles from edges using the distance cutoff $distance, from $argv[$i] to be  $newbox  "
else
echo "$box does not exists, or wrong format or suffix not .box"
endif

@ i++

end

exit
