#!/bin/tcsh -f

#####**************************************************************************#####
#Despcription: This program is used to replace three defocus colume U,V,A by other star files
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

set args =  ${#argv}
set Proc_name=`echo $0 | awk '{n=split($1,scr,"/");print scr[n];}'`

if ( $args < 2 || $1 == '--help' || $1 == '-h' ) then

        printf "\n${KBold}Despcription:${KDefault} This program is used to replace three defocus colume U,V,A of a particle stack star file by local CTF star files from each individual micrographs.\n"
        printf "${KBold}             ${KDefault} It's quite useful for local CTF refinement of each particle.\n"
 
        printf "${KBold}Usage:${KDefault}        $Proc_name  <original particle star> <local star1> [local star2] [...] \n"
        printf "${KBold}Example:${KDefault}      $Proc_name run3_good1_after3D_data.star  Micrographs/Falcon*_local.star\n\n"
        printf "${KBold}NOTE:${KDefault}         run3_good1_after3D_data.star is a typical particle stack STAR file after 3D classfication/refinement. It can be a partial STAR file from the entire particles.star.\n"
        printf "              *_local.star MUST be generated using exactly the same .box/.star file for particle extraction.\n"
        printf "              Assume you have mic001.mrc mic002.mrc mic003.mrc in the Micrographs/ folder. Then you have mic001_autopick.star mic002_autopick.star  mic003_autopick.star in the  Micrographs/ folder as well, which represent the coordinates of each micrograph respectively.\n"
        printf "              You have used *_autopick.star to extract all particles that generated a star file, particles.star and you have done 2D, 3D etc and god a finally clean stack, run3_good1_after3D_data.star\n"
        printf "              At the same time, you did local CTF useing this command 'Gctf --do_local_refine --boxsuffix _autopick.star Micrographs/mic*.mrc' and generated mic001_local.star  mic002_local.star mic003_local.star\n"
        printf "              Finally, you could simply use the following command to replace all CTF information of run3_good1_after3D_data.star by \n"
        printf "              ${KBold}$Proc_name run3_good1_after3D_data.star  Micrographs/Falcon*_local.star${KDefault}\n\n"


        exit(1)
endif


set raw_starf="$argv[1]"
set root=`basename $raw_starf .star`
set new_starf=${root}_localUVA.star
set all_localstarf=all_local$$.star

echo "original star file: $raw_starf"
shift

set firs_localstarf=$argv[1]
set headN=`gawk 'NR < 100 {if($2 ~ /#/)N=NR;}END{print N}'  $firs_localstarf`
gawk 'NR <= '$headN''  $firs_localstarf  > $all_localstarf

set headN=`gawk 'NR < 100 {if($2 ~ /#/)N=NR;}END{print N}' $raw_starf `
gawk 'NR <= '$headN'' $raw_starf   > $new_starf



set raw_rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $raw_starf  |cut -c 2- `
set raw_rlnDefocusUIndex=`gawk 'NR<50 && /_rlnDefocusU/{print $2}'  $raw_starf |cut -c 2- `
set raw_rlnDefocusVIndex=`gawk 'NR<50 && /_rlnDefocusV/{print $2}'  $raw_starf |cut -c 2- `
set raw_rlnDefocusAngleIndex=`gawk 'NR<50 && /_rlnDefocusAngle/{print $2}'  $raw_starf |cut -c 2- `
set raw_rlnMicrographNameIndex=`gawk 'NR<50 && /_rlnMicrographName/{print $2}' $raw_starf  |cut -c 2- `

set local_rlnImageNameIndex=`gawk 'NR<50 && /_rlnImageName/{print $2}' $firs_localstarf  |cut -c 2- `
set local_rlnDefocusUIndex=`gawk 'NR<50 && /_rlnDefocusU/{print $2}'  $firs_localstarf |cut -c 2- `
set local_rlnDefocusVIndex=`gawk 'NR<50 && /_rlnDefocusV/{print $2}'  $firs_localstarf |cut -c 2- `
set local_rlnDefocusAngleIndex=`gawk 'NR<50 && /_rlnDefocusAngle/{print $2}'  $firs_localstarf |cut -c 2- `
set local_rlnMicrographNameIndex=`gawk 'NR<50 && /_rlnMicrographName/{print $2}' $firs_localstarf  |cut -c 2- `


set local_keywordN=`gawk 'NR < 100 {if( $1 ~ "_rln" &&  $2 ~ /#/ )N++;}END{print N }' $firs_localstarf `
set local_keywordNplus=`gawk 'NR < 100 {if( $1 ~ "_rln" &&  $2 ~ /#/ )N++;}END{print N + 1 }' $firs_localstarf `




###################       generate an entire stack of particle after local CTF refinement     ##########################
foreach localstarf ( $argv )
gawk '/mrc/{i++; printf("%s  %06d\n",$0, i)}' $localstarf >> $all_localstarf
end

#replacing the 
gawk  'BEGIN{}/mrc/{\
if(FILENAME==ARGV[1]){image=$'$raw_rlnImageNameIndex'; split(image, strimage, "@");  ImageId =strimage[1];   data_raw[$'$raw_rlnMicrographNameIndex', ImageId] = $0; } \
if(FILENAME==ARGV[2]){ImageId = $'$local_keywordNplus'; data_rf[$'$local_rlnMicrographNameIndex', ImageId] = $0; } }\
END{\
    for ( i in data_raw ) {\
        n_raw=split(data_raw[i], str_raw, " ");\
        n_rf=split(data_rf[i], str_rf, " ");\
        for (j=1;j<=n_raw;j++){\
            if      ( j == '$raw_rlnDefocusUIndex' )     printf("%s  ",str_rf['$local_rlnDefocusUIndex']);\
            else if ( j == '$raw_rlnDefocusVIndex' )     printf("%s  ",str_rf['$local_rlnDefocusVIndex']);\
            else if ( j == '$raw_rlnDefocusAngleIndex' ) printf("%s  ",str_rf['$local_rlnDefocusAngleIndex']);\
            else printf("%s  ",str_raw[j]);\
        }\
        printf("\n");\
    }\
}  '   $raw_starf   $all_localstarf >> $new_starf

echo "new star file $new_starf generated."

rm -rf $all_localstarf


exit

