#!/bin/bash

#################################################################
# this script will filter ctf parameters form summry [.txt] file
# of CTFFIND4.
# the scripts will output a .STAR file to use in Relion.
# befor running make sure the right path to your micrographs <var>
# and adjust the range <i>.
# 
# run script: scriptname.sh <output_file>
# Elad Binshtein   05212016 V1
############Variables############################################
fmax_d=40000 #default defocus_cutoffmax
fmin_d=10000 #default defocus_cutoffmin
r_d=7    #default resulotion_cutoff
Apix_d=1.24668595 #default A/pix
var=Micrographs2/sILSTAP_
#################################################################

if [ "$1" == "" ] ; then
 echo " === Usage: === "
 echo " $0 <output_file_name>"
 echo "    "
 exit
fi

#read -p "enter input file name: " filename

read -p  "max defocus cutoff (A) [$fmax_d]: " fmax
fmax=${fmax:-$fmax_d}

read -p  "min defocus cutoff (A) [$fmin_d]: " fmin
fmin=${fmin:-$fmin_d}

read -p "resolution cutoff [$r_d]: " r
r=${r:-$r_d}

read -p "A/pix [$Apix_d]: " Apix
Apix=${Apix:-$Apix_d}

echo "cutoff parameters:" "max defocus=" $fmax "min defocus=" $fmin "max resolution=" $r
echo "           "

for i in {0001..4432}
do

ctf=( `egrep -a "0.000000" $var${i}_cor.txt` )
ip=( `egrep -a "Pixel size" $var${i}_cor.txt` )
image=( `egrep -ao "Micrographs2/sILSTAP_...._cor.mrc" $var${i}_cor.txt` )
imagectf=("${image[@]}" "${ctf[@]}" "${ip[@]}")


echo ${imagectf[@]} |  awk -v Apix="$Apix" '   
	  {printf("  %10.6f %10.6f %10.6f    %10.6f   %10.6f   %10.6f   %10.6f  %10.6f     %6.6f %s  %10.2f\n", $15,$3,$4,$5,$18,5.0000,$7,50000/Apix, $21,$1, $8 )}' >> ${1}.temp

done

#
relion_star_loopheader "rlnVoltage #1" "rlnDefocusU #2" "rlnDefocusV #3" "rlnDefocusAngle #4" "rlnSphericalAberration #5" "rlnDetectorPixelSize #6" "rlnCtfFigureOfMerit #7" "rlnMagnification #8" "rlnAmplitudeContrast #9" "rlnMicrographName #10" "rlnFinalResolution #11" > ${1}.star
#

awk -v r="$r" -v fmax="$fmax" -v fmin="$fmin" '$11<r && $3>fmin && $2<fmax' < ${1}.temp >> ${1}.star
rm -f ${1}.temp



