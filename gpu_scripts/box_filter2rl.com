#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: This program is used to filter box files in EMAN1 format to Relion star
#so that the filtered box files fit a certain range of ccc values
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-5-11

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup


#set args = `printf "$argv" | wc | awk '{print $2}'`
set args = ${#argv}

set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args <= 1 || $1 == '--help' || $1 == '-h' ) then


        printf "${KBold}Despcription: ${KDefault}This program is used to filter box files in EMAN1 format  to Relion star file by CCC.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <min CC> <max CC> <box file1> [box file2] [...] \n"
        printf "${KBold}example:${KDefault} $Proc_name 0.3 1.5 data_1001.box\n"
        printf "${KBold}example:${KDefault} $Proc_name 0.5 1.0 data_1???.box\n"

        exit(1)
endif

set ccmin=$argv[1]
set ccmax=$argv[2]

set min_max_swap=`echo $ccmin $ccmax |gawk '//{if($1 > $2){printf("1");} else {printf("0")}}' `

if ( $min_max_swap == 1 )then
set ccmin=$argv[2]
set ccmax=$argv[1]

endif



set i=3

while ($i <= $args )

set box=$argv[$i]
set root=`basename $box .box`

if ( -f ${root}.box) then

set starf=${root}_filter.star
echo "" > $starf
echo "data_" >> $starf
echo "" >> $starf
echo "loop_" >> $starf
echo "_rlnCoordinateX #1" >> $starf
echo "_rlnCoordinateY #2" >> $starf
echo "_rlnClassNumber #3" >> $starf
echo "_rlnAutopickFigureOfMerit #4" >> $starf



gawk '/[0-9]/{if( '$ccmin' < $5 && $5 < '$ccmax' )printf("%d\t%d\t%d\t%.6f\n",$1+ $3/2, $2 + $4/2,$6 , $5)}' $box >>  $starf

echo "filtering $argv[$i] $starf into by CCC range from $ccmin to $ccmax..."
else
echo "$box does not exists, or wrong format or suffix not .box"
endif

@ i++

end

exit
