#!/bin/tcsh -f

#####**************************************************************************#####
#Despcription: This program is used to reorder the star files using a template star file
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

if ( $args < 1 || $1 == '--help' || $1 == '-h' ) then

        printf "${KBold}Despcription: ${KDefault}This program is used to reorder the star files using template.star file.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <star file1> [star file2] [...] \n"
      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge Dr. Kai Zhang from MRC-LMB.  >>>>>${KDefault}\n"

        exit(1)
endif

set all_data_starf="$argv"
set head_starf="template.star"

set keywordN=`gawk 'NR < 100 {if($2 ~ /#/)N=$2;}END{print N}' $head_starf |cut -c 2- `
set headN=`gawk 'NR < 100 {if($2 ~ /#/)N=NR;}END{print N}' $head_starf `


#######################################################################################################################################
#######################################################################################################################################
#######################################################################################################################################
foreach data_starf ( $all_data_starf )

set root=`basename $data_starf .star`
set reorder_starf="${root}_reorder.star"

echo "reodering $data_starf to ${root}_reorder.star ..."
set index=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
#echo $keywordN

set i=1

while ( $i <= $keywordN )


set keyword=`gawk 'NR < 100 {if($2 ~ /#/  && substr($2, 2, length($1) ) == '$i' )print $1}' $head_starf`
set index[$i]=`gawk 'NR < 100 {if($2 ~ /#/  && $1 == "'$keyword'" )print $2}' $data_starf |cut -c 2- `
#echo $keyword $index[$i]

@ i++
end


gawk 'NR <= '$headN'' $head_starf > $reorder_starf


gawk '/mrc/{for(i=1;i<='$keywordN';i++){\
if(i==1)printf("%s ", $'$index[1]');\
else if(i==2)printf("%s ", $'$index[2]'); \
else if(i==3)printf("%s ", $'$index[3]'); \
else if(i==4)printf("%s ", $'$index[4]'); \
else if(i==5)printf("%s ", $'$index[5]'); \
else if(i==6)printf("%s ", $'$index[6]'); \
else if(i==7)printf("%s ", $'$index[7]'); \
else if(i==8)printf("%s ", $'$index[8]'); \
else if(i==9)printf("%s ", $'$index[9]'); \
else if(i==10)printf("%s ", $'$index[10]'); \
else if(i==11)printf("%s ", $'$index[11]'); \
else if(i==12)printf("%s ", $'$index[12]'); \
else if(i==13)printf("%s ", $'$index[13]'); \
else if(i==14)printf("%s ", $'$index[14]'); \
else if(i==15)printf("%s ", $'$index[15]'); \
else if(i==16)printf("%s ", $'$index[16]'); \
else if(i==17)printf("%s ", $'$index[17]'); \
else if(i==18)printf("%s ", $'$index[18]'); \
else if(i==19)printf("%s ", $'$index[19]'); \
else if(i==20)printf("%s ", $'$index[20]'); \
else if(i==21)printf("%s ", $'$index[21]'); \
else if(i==22)printf("%s ", $'$index[22]'); \
else if(i==23)printf("%s ", $'$index[23]'); \
else if(i==24)printf("%s ", $'$index[24]'); \
else if(i==25)printf("%s ", $'$index[25]'); \
else if(i==26)printf("%s ", $'$index[26]'); \
else if(i==27)printf("%s ", $'$index[27]'); \
else if(i==28)printf("%s ", $'$index[28]'); \
else if(i==29)printf("%s ", $'$index[29]'); \
else if(i==30)printf("%s ", $'$index[30]'); \
else if(i==31)printf("%s ", $'$index[31]'); \
else if(i==32)printf("%s ", $'$index[32]'); \
else if(i==33)printf("%s ", $'$index[33]'); \
else if(i==34)printf("%s ", $'$index[34]'); \
else if(i==35)printf("%s ", $'$index[35]'); \
else if(i==36)printf("%s ", $'$index[36]'); \
else if(i==37)printf("%s ", $'$index[37]'); \
else if(i==38)printf("%s ", $'$index[38]'); \
else if(i==39)printf("%s ", $'$index[39]'); \
else if(i==40)printf("%s ", $'$index[30]'); \
else if(i==41)printf("%s ", $'$index[31]'); \
else if(i==42)printf("%s ", $'$index[32]'); \
else if(i==43)printf("%s ", $'$index[33]'); \
else if(i==44)printf("%s ", $'$index[34]'); \
else if(i==45)printf("%s ", $'$index[35]'); \
else if(i==46)printf("%s ", $'$index[36]'); \
else if(i==47)printf("%s ", $'$index[37]'); \
else if(i==48)printf("%s ", $'$index[38]'); \
else if(i==49)printf("%s ", $'$index[39]'); \
} printf("\n");}' $data_starf >> $reorder_starf


end



      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

