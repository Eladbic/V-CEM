#!/bin/tcsh -f


#####**************************************************************************#####
#Despcription: This program is used to create all individual classes from classes.star
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-7-8

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


        printf "${KBold}Despcription: ${KDefault}This program is used to create all individual classes from 2D results of RELION.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <class star file>  \n"
        printf "${KBold}example:${KDefault} $Proc_name star_classes_data.star \n"


        exit(1)
endif


####################################################################################################

set class_starf=${1}
if ( ! -f $class_starf ) then
echo "star file '$class_starf' doesn't exist! Check the input option and files!"
exit
endif
set root_name=`echo $class_starf | sed  's/.star//g' `

set is_imgname_exist = `grep rlnImageName $class_starf`

if ( "$is_imgname_exist" == "" ) then
sed -i 's/rlnReferenceImage/rlnImageName/g' $class_starf
set Refimg_replaced = 1 
endif

#getting classes from star file
set rlnClassNumberIndex2=`gawk 'NR<50 && /_rlnClassNumber/{print $2}' $class_starf |cut -c 2- `
set class_ids=`gawk '/mrcs/{printf("%d ",$'$rlnClassNumberIndex2')}' $class_starf`
#end getting classes

echo "creating mrc files of all classes using star file $class_starf as input ... "

echo "${#class_ids} classes to be created ..."

#######################
set i=1

set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}'  $class_starf`
set columnN=`gawk 'NR<50 && /_rln/{a=$2;}END{print a;}' $class_starf |cut -c 2- `



set curr_starf=${root_name}.star

relion_stack_create --i  $curr_starf --o $root_name  > /dev/null

echo
#######################

if ( Refimg_replaced == 1 ) then
sed -i 's/rlnImageName/rlnReferenceImage/g' $class_starf
endif

      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

