#!/bin/tcsh -f



#####**************************************************************************#####
#Despcription: This program is used to show the infomation of star files
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-4-6

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup

set args = ${#argv}
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`


if ( $args < 1 || $1 == '--help' || $1 == '-h' ) then


        printf "${KBold}Despcription: ${KDefault}This program is used to  show the infomation of star files\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <star file1> [star file2] [star file3] ... \n"

        exit(1)
endif


set i=1
set sum=0

while  ($i <= $args )


set rlnCoordinateXIndex=`gawk 'NR<50 && /_rlnCoordinateX/{print $2}' ${argv[$i]} |cut -c 2- `
set rlnCoordinateYIndex=`gawk 'NR<50 && /_rlnCoordinateY/{print $2}' ${argv[$i]} |cut -c 2- `


set rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' ${argv[$i]}   |cut -c 2- `
if ( $rlnImageNameIndex == ""  && ( $rlnCoordinateXIndex == "" ||  $rlnCoordinateYIndex == "" ) )then 
set num=`gawk '/mrcs/' ${argv[$i]} | wc | gawk '//{print $1}'`
echo "${argv[$i]} contains $num particles"
@ sum = $sum + $num


else if ( $rlnImageNameIndex == ""  && ( ! ($rlnCoordinateXIndex == "") ) && ( ! ( $rlnCoordinateYIndex == "" ) )  )then

set num=`gawk '$'$rlnCoordinateXIndex'~/[0-9]/ && $'$rlnCoordinateYIndex'~/[0-9]/' ${argv[$i]} | wc | gawk '//{print $1}'`
echo "${argv[$i]} contains $num particle coordinates"

@ sum = $sum + $num

else if ( ! ( $rlnImageNameIndex == "" ) ) then

set num=`gawk '$'$rlnImageNameIndex'~/mrcs/' ${argv[$i]} | wc | gawk '//{print $1}'`
echo "${argv[$i]} contains $num particles"
@ sum = $sum + $num


endif


@ i++

end  #end while

echo "There are $sum partilces in total."
      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

