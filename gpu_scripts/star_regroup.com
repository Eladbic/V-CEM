#!/bin/tcsh -f
#####**************************************************************************#####
#Despcription: }This program is used to regroup the particels of a star file based on defocus.
#Copyright@MRC-LMB
#Author: Kai Zhang
#Last Edit: 2014-8-1

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

        printf "${KBold}Despcription: ${KDefault}This program is used to regroup the particels of a star file based on defocus.\n"
        printf "              One additional column _rlnGroupName will be added if not present.\n"
        printf "              If _rlnGroupName is already present, it will be replaced by the new name.\n"
        printf "${KBold}Usage:${KDefault}   $Proc_name <max number per group> <star file1> <star file2> ...\n"
        printf "${KBold}example:${KDefault} $Proc_name 100 r3d2_cls2_data.star  \n"
      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge Dr. Kai Zhang from MRC-LMB.  >>>>>${KDefault}\n"

        exit(1)
endif



set input=$2
set rgN=$1

set group_diff=100


set root=`basename $input .star`
set output=${root}_rg${rgN}.star
set rlnMicrographNameIndex=`gawk 'NR<50 && /_rlnMicrographName/{print $2}' $input   |cut -c 2- `
set rlnDefocusUIndex=`gawk 'NR<50 && /_rlnDefocusU/{print $2}' $input   |cut -c 2- `
set rlnDefocusVIndex=`gawk 'NR<50 && /_rlnDefocusV/{print $2}' $input   |cut -c 2- `

set rlnGroupNameIndex=`gawk 'NR<50 && /_rlnGroupName/{print $2}' $input   |cut -c 2- `
set rlnGroupNumberIndex=`gawk 'NR<50 && /_rlnGroupNumber/{print $2}' $input   |cut -c 2- `
set keywordN=`gawk 'NR < 100 {if($2 ~ /#/)N=$2;}END{print N}' $input |cut -c 2- `

set headN=`gawk 'NR < 100 {if($2 ~ /#/)N=NR;}END{print N}' $input `
gawk 'NR <= '$headN'' $input  > $output

@ keywordNplus = $keywordN + 1
@ keywordNplusplus = $keywordN + 2
@ rlnDefocusAveIndex =  $keywordN + 1

gawk '/mrcs/{for(i=1;i<='$keywordN';i++)printf("%s ", $i); printf("%f \n", ($'$rlnDefocusUIndex' + $'$rlnDefocusVIndex') / 2 );}'  $input |sort -n -k $rlnDefocusAveIndex > temp$$.star 


if ( $rlnGroupNameIndex == "" &&  $rlnGroupNumberIndex == "" ) then
echo "_rlnGroupNumber #$keywordNplus" >> $output
echo "_rlnGroupName #$keywordNplusplus" >> $output
gawk 'BEGIN{G=0; Upre=0; Ucur=0; count=0; }/mrcs/{Ucur=$'$rlnDefocusAveIndex'; if( (Ucur - Upre > '$group_diff' ) && ( count > '$rgN') ){G++; count=0;Upre=Ucur;} for(i=1;i<='$keywordN';i++){ printf("%s ", $i); }  printf("%d  group_%04d  \n",G, G); count++; }' temp$$.star >> $output


else if ( $rlnGroupNameIndex == "" &&  !($rlnGroupNumberIndex == "") ) then
echo "_rlnGroupName #$keywordNplus" >> $output
gawk 'BEGIN{G=0; Upre=0; Ucur=0; count=0; }/mrcs/{Ucur=$'$rlnDefocusAveIndex'; if( (Ucur - Upre > '$group_diff') && ( count > '$rgN') ){G++; count=0;Upre=Ucur;} for(i=1;i<='$keywordN';i++){ if(i=='$rlnGroupNumberIndex') printf("%d  ", G); else printf("%s ", $i); }  printf("group_%04d  \n",G ); count++; }' temp$$.star >> $output

else if ( !($rlnGroupNameIndex == "") &&  $rlnGroupNumberIndex == "" ) then
echo "_rlnGroupNumber #$keywordNplus" >> $output
gawk 'BEGIN{G=0; Upre=0; Ucur=0; count=0; }/mrcs/{Ucur=$'$rlnDefocusAveIndex'; if( (Ucur - Upre > '$group_diff' ) && ( count > '$rgN') ){G++; count=0;Upre=Ucur;} for(i=1;i<='$keywordN';i++){ if(i=='$rlnGroupNameIndex') printf("group_%04d  ", G); else printf("%s ", $i); }  printf("d\n",G); count++; }' temp$$.star >> $output


else
gawk 'BEGIN{G=0; Upre=0; Ucur=0; count=0; }/mrcs/{Ucur=$'$rlnDefocusAveIndex'; if( ( Ucur - Upre > '$group_diff' ) && ( count > '$rgN') ){G++; count=0;Upre=Ucur;} for(i=1;i<='$keywordN';i++){ if(i=='$rlnGroupNumberIndex') printf("%d  ", G); else if(i=='$rlnGroupNameIndex') printf("group_%04d ",G); else printf("%s ", $i); } printf("\n");  count++; }' temp$$.star >> $output
endif


rm -f temp$$.star


exit

      printf "${KBold}<<<<<  A Kind Reminding: if you find this script useful, please acknowledge the link to get the script  'http://www.mrc-lmb.cam.ac.uk/kzhang/useful_tools/'   >>>>>${KDefault}\n"

