#!/bin/tcsh -f



#####**************************************************************************#####
#Despcription: This program is used to extract a star file for multiple classes from RELION results
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2015-1-8

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup

set args = `printf "$argv" | wc | awk '{print $2}'`
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`


if ( $args < 3 || $1 == '--help' || $1 == '-h' ) then


        printf "${KBold}Despcription: ${KDefault}This program is used to extract a star file for multiple classes from RELION results\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <star file>  <extraction options> [classes]\n"
        printf "${KBold}example:${KDefault} $Proc_name relion_it010_data.star IDs 2 3 8 32  \n"
        printf "         This will extract class 2 3 8 32 from star file and generate seperate star files for each class whose index is 2 3 8 or 32\n"
        printf "\n"

        printf "         $Proc_name relion_it010_data.star Star clases_good_it025.star \n"
        printf "         $Proc_name relion_it010_data.star Lst clases_good_it025.lst \n"
        printf "         $Proc_name relion_it010_data.star Best 20 \n"
        printf "         $Proc_name relion_it010_data.star Best 20%% \n"
        printf "         $Proc_name relion_it010_data.star All  28\n"

        exit(1)
endif


####################################################################################################
set input_starf=${1}
set Extype=${2}

if ( ! -f $input_starf ) then
        printf "${KBold}Error: ${KDefault}star file ${KFlash}$input_starf ${KDefault}does not exist!\n"
        exit(1)
endif


####################################################################################################
#set rlnMicrographNameIndex=`gawk 'NR<50 && /_rlnMicrographName/{print $2}' $input_starf |cut -c 2- `
#set rlnCoordinateXIndex=`gawk 'NR<50 && /_rlnCoordinateX/{print $2}' $input_starf |cut -c 2- `
#set rlnCoordinateYIndex=`gawk 'NR<50 && /_rlnCoordinateY/{print $2}' $input_starf |cut -c 2- `
#set rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $input_starf |cut -c 2- `
#set rlnDefocusUIndex=`gawk 'NR<50 && /_rlnDefocusU/{print $2}' $input_starf |cut -c 2- `
#set rlnDefocusVIndex=`gawk 'NR<50 && /_rlnDefocusV/{print $2}' $input_starf |cut -c 2- `
#set rlnDefocusAngleIndex=`gawk 'NR<50 && /_rlnDefocusAngle/{print $2}' $input_starf |cut -c 2- `
#set rlnVoltageIndex=`gawk 'NR<50 && /_rlnVoltage/{print $2}' $input_starf |cut -c 2- `
#set rlnSphericalAberrationIndex=`gawk 'NR<50 && /_rlnSphericalAberration/{print $2}' $input_starf |cut -c 2- `
#set rlnAmplitudeContrastIndex=`gawk 'NR<50 && /_rlnAmplitudeContrast/{print $2}' $input_starf |cut -c 2- `
#set rlnMagnificationIndex=`gawk 'NR<50 && /_rlnMagnification/{print $2}' $input_starf |cut -c 2- `
#set rlnDetectorPixelSizeIndex=`gawk 'NR<50 && /_rlnDetectorPixelSize/{print $2}' $input_starf |cut -c 2- `
#set rlnCtfFigureOfMeritIndex=`gawk 'NR<50 && /_rlnCtfFigureOfMerit/{print $2}' $input_starf |cut -c 2- `

set rlnClassNumberIndex=`gawk 'NR<50 && /_rlnClassNumber/{print $2}' $input_starf |cut -c 2- ` 
####################################################################################################


set input_star_base=`basename $input_starf .star`
set output_star_base="${input_star_base}_class"

####################################################################################################
if ( $Extype =~ "i*" || $Extype =~ "I*"  || $Extype  =~  "-i*"   || $Extype   =~ "-I*"   || $Extype   =~ "--i*"   || $Extype =~ "--I*" ) then
#<<< if1003
echo "extracting classes from $input_starf using class IDs as input ... "
set classN=`echo $args |gawk '//{print $1 - 2}'`
echo "$classN classes to be extracted ..."
printf "extracting "
set output_starfall="${output_star_base}all.star"
gawk '! /mrcs/ && NR < 50' $input_starf > $output_starfall

set i=3

while  ($i <= $args )

set class_id=${argv[$i]}
set regI=`echo $class_id |gawk '//{printf("%04d", $1)}'`

set output_starf="${output_star_base}${regI}.star"


gawk '! /mrcs/ &&  NR < 50' $input_starf > $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$class_id' ){print $0 } }'  $input_starf >> $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$class_id' ){print $0 } }'  $input_starf >> $output_starfall

printf "$regI "

@ i++

end  #end while
echo

endif 
#>>> if1003

####################################################################################################

####################################################################################################
if ( $Extype =~ "S*" || $Extype =~ "s*"  || $Extype  =~  "-S*"   || $Extype   =~ "-s*"   || $Extype   =~ "--S*"   || $Extype =~ "--s*" ) then
#<<< if1004

set class_starf=${3}
if ( ! -f $class_starf ) then
echo "star file '$class_starf' doesn't exist! Check the input option and files!"
exit
endif

#getting classes from star file
set rlnClassNumberIndex2=`gawk 'NR<50 && /_rlnClassNumber/{print $2}' $class_starf |cut -c 2- ` 
set class_ids=`gawk '/mrcs/{printf("%d ",$'$rlnClassNumberIndex2')}' $class_starf`
#end getting classes

if ( ${#class_ids} > 500 ) then
echo "Too many classes, over 500! Are you sure you are using the correct star files?"
endif

echo "extracting classes from $input_starf using star file $class_starf as input ... "

echo "${#class_ids} classes to be extracted ..."
printf "extracting "

set output_starfall="${output_star_base}all.star"
gawk '! /mrcs/ && NR < 50' $input_starf > $output_starfall

#######################
set i=1

while ( $i <= ${#class_ids} )

set regI=`echo $class_ids[$i] |gawk '//{printf("%04d", $1)}'`
set cid=$class_ids[$i] 
set output_starf="${output_star_base}${regI}.star"
gawk '! /mrcs/ &&  NR < 50 ' $input_starf > $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$cid' ){print $0 } }'  $input_starf >> $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$cid' ){print $0 } }'  $input_starf >> $output_starfall

printf "$regI "

@ i++
end
echo
#######################


endif
#>>> if1004

####################################################################################################
if ( $Extype =~ "a*" || $Extype =~ "A*"  || $Extype  =~  "-a*"   || $Extype   =~ "-A*"   || $Extype   =~ "--a*"   || $Extype =~ "--A*" ) then
#<<< if1003
echo "extracting all classes from $input_starf  ... "
set classN=${argv[3]}
echo "$classN classes to be extracted ..."
printf "extracting "
set output_starfall="${output_star_base}all.star"
gawk '! /mrcs/ && NR < 50' $input_starf > $output_starfall

set i=1

while  ($i <=  $classN )

set class_id=$i
set regI=`echo $class_id |gawk '//{printf("%04d", $1)}'`

set output_starf="${output_star_base}${regI}.star"


gawk '! /mrcs/ &&  NR < 50 ' $input_starf > $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$class_id' ){print $0 } }'  $input_starf >> $output_starf
gawk '//{if($'$rlnClassNumberIndex' == '$class_id' ){print $0 } }'  $input_starf >> $output_starfall

printf "$regI "

@ i++

end  #end while
echo

endif 
#>>> if1003

####################################################################################################

      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"



exit

