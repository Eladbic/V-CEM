#!/bin/bash

#################################################################
# this script will filter ctf parameters form partres.txt
# of sxcter.py.
# the scripts will output a .STAR file to use in Relion.
# befor running make sure the right path to your file <var> and set the cutoff threshold
# 
# run script: scriptname.sh <output_file>
# Elad Binshtein   05212016 V1
############Variables############################################
fmax_d=40000 #default defocus_cutoffmax
fmin_d=10000 #default defocus_cutoffmin
fdev_d=0.5 #default defocus_error
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

read -p "enter input file name: " filename

read -p  "max defocus cutoff (A) [$fmax_d]: " fmax
fmax=${fmax:-$fmax_d}

read -p  "min defocus cutoff (A) [$fmin_d]: " fmin
fmin=${fmin:-$fmin_d}

read -p  "max std dev defocus (A) [$fdev_d]: " fdev
fdev=${fdev:-$fdev_d}

read -p "resolution cutoff [$r_d]: " r
r=${r:-$r_d}

read -p "A/pix [$Apix_d]: " Apix
Apix=${Apix:-$Apix_d}

echo "cutoff parameters:" "max defocus=" $fmax "min defocus=" $fmin "max resolution=" $r
echo "           "

awk -v r="$r" -v fmax="$fmax" -v fmin="$fmin" -v fdev="$fdev" '$12>1/r && $1*10000>fmin && $1*10000<fmax && $9<fdev' < ${filename} >> ${1}.temp


#
relion_star_loopheader "rlnVoltage #1" "rlnDefocusU #2" "rlnDefocusV #3" "rlnDefocusAngle #4" "rlnSphericalAberration #5" "rlnDetectorPixelSize #6" "rlnMagnification #7" "rlnAmplitudeContrast #8" "rlnMicrographName #9" "rlnFinalResolution #10" > ${1}.star
#
awk -v Apix="$Apix" '   
	  {printf("  %10.6f %10.6f %10.6f    %10.6f   %10.6f   %10.6f    %10.6f     %6.6f %s  %10.2f\n", $3,$1*10000,$1*10000,$8,$2,5.0000,50000/Apix, $0.1,$14, 1/$12 )}' ${1}.temp >> ${1}.star

rm -f ${1}.temp



