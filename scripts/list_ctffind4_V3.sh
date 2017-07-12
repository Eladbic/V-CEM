#!/bin/bash 

#################################################################
# this script will list ctf parameter form ctffind4 summry file [.txt]
# change {var} file name path and {i} first and last file number.
# output will give list of all ctf parameters and mic#  
#
# run script: scriptname.sh  <output_file>
# Elad Binshtein 051716 V3
############Variables############################################

var=Micrographs2/sILSTAP_
#################################################################

if [ "$1" == "" ] ; then
 echo " === Usage: === "
 echo " $0 <output_file_name>"
 echo "    "
 exit
fi

awk ' BEGIN{i=1; printf("micrograph				reso_A   defocus1   defocus2      diff     Ast_angle      CC\n\n")}' > ${1}.parm

for i in {0001..4432}
do

ctf=( `egrep -a "0.000000" $var${i}_cor.txt` )
image=( `egrep -ao "$var...._cor.mrc" $var${i}_cor.txt` )
imagectf=("${image[@]}" "${ctf[@]}")


echo ${imagectf[@]} |  awk '   
	  {printf("%s %10.2f  %10.2f %10.2f  %10.2f    %6.2f        %6.6f\n", $1,$8, $3,$4, $3-$4, $5, $7)}' >> ${1}.parm
done
