#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: }This program is used to seperate a star file into multiple ones.
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-10-16

#####**************************************************************************#####

#global setup for output format
set KBold="\x1b\x5b1m"
set KDefault="\x1b\x5b0m"
set KUnderline="\x1b\x5b4m"
set KFlash="\x1b\x5b5m"

#end of global setup

set args = `printf "$argv" | wc | awk '{print $2}'`
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args < 2 || $1 == '--help' || $1 == '-h' ) then

        printf "${KBold}Despcription: ${KDefault}This program is used to seperate a star file into multiple ones.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <star file1> <number> \n"
        printf "${KBold}example:${KDefault} $Proc_name r3d2_data.star 10 \n"

        exit(1)
endif


set starf=$argv[1]
set number=$argv[2]

set root=`basename $starf .star`

if ( -f ${root}.star) then

set headN=`gawk '{if($2 ~ /#/)N=NR;}END{print N}' $starf `
set total_num=`gawk '/mrcs/' $starf | wc | gawk '//{print $1}'`
gawk 'NR <= '$headN'' $starf > head_tmp$$.star

set i=1


while ( $i <= $number ) 

set regI=`echo $i |gawk '//{printf("%03d",$1)}'`

set starf_new=${root}_sub${regI}.star

set first=`echo $i $headN $total_num $number |gawk '//{ group_number = int( ($3 + $4 - 1) /$4); printf("%d",($1  - 1 )* group_number + $2 + 1 ); }'`
set last=`echo $i $headN $total_num $number |gawk '//{ group_number = int( ($3 + $4 - 1) /$4); printf("%d",$1 * group_number  + $2 ); }'`

cp head_tmp$$.star $starf_new
echo "separating  $starf to $total_num $starf_new $first $last"
gawk 'NR <= '$last' && NR >= '$first' ' $starf >> $starf_new

@ i++
end

else
echo "$starf does not exists, or wrong format or suffix not .star"

endif

rm -f head_tmp$$.star
      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

