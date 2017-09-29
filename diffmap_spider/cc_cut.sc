#!/bin/tcsh -f
# 
# This script is designed to be run in a "cluster" directory for an alignment
# It assumes that you have "selXXX.ext files that list the members of each class,
# a stack named "../data002.ext" that has all the particles, and finally, averages
# named "avgXXX.ext" to correlate against.  To run: edit the variables in the header
# and then use the command ./cc_cut.sc > cc_cut.log & . It will output 2 files for each
# group it is run for. First a corr_XXX.ext wich holds ALL the correlation information
# and a "out"_XXX.ext that contains the best particles for that group
#
# Implementation: DEC and SGI
# Last modified: Wed Apr 10 12:13:47 EDT 2002


###########
# VARIABLES
###########

set ext = "spl"				# The data extension associated with this project
set output_file = "good_particles"	# the output of this procedure (a document file)
set num_groups = 3			# the number of groups in the alignment
set avg_or_percent = 1			# IF = 1 then take only those particles at or above the average correlation
					# IF = 2 then take a certain percentage of the best particles
set percent = 30			# the percent of particles to take if avg_or_percent = 2

###########
# PROGRAM - no edits
###########

# Crash if they set the avg_or_percent wrong
if (($avg_or_percent != 1 ) && ( $avg_or_percent != 2 )) then
	printf "\n\navg_or_percent is set WRONG please edit\n\n"
	exit()
endif


# SPIDER part to do the correlations
# set up spider for OS
set OS = `echo $HOSTTYPE`
if ($OS == "i386-linux") set spider   = "/programs/i386-linux/spider/8.02/bin/spider"
if ($OS == "iris4d") set spider   = "/programs/iris4d/spider/8.02/spider/bin/spider5"

$spider <<EOSc
ccc/$ext

; script to check the correlation of the images with thier respective averages
; use in the last cluster of a mra.  
; it cross corelates the images in a group to the group average and then orders
; the results so that the highest correlated particles are at the bottom (makes
; viewing easier)


; x10 = number of groups
x10=$num_groups

; loop for group number
do lb1 x11=1,x10
ud n,x12
sel{***x11}
ud e
; loop for images in group
do lb2 x13=1,x12
ud x13,x14
sel{***x11}
cc n
ref{***x11}
../data002@{*****x14}
_1
pk x15,x16,x17
_1
(1)

sd x0,x14,x17
tmpA{***x11}
lb2
doc sort
tmpA{***x11}
corr_{***x11}
(2)
Y
lb1
vm 
rm tmpA*
en d
EOSc


# Shell part to actually cut out the proper info 
set sel = "corr_"
set i = 1
while( $i <= ${num_groups})
	set inum=`echo ${i}|awk '{printf("%03d\n",$1)}'`
	if ($avg_or_percent == 1) then
		grep ";" corr_$inum.$ext > ${output_file}_${inum}.${ext}
		set average = `echo "${sel}${inum}.${ext}" | awk 'BEGIN{n=0; avg=0}{sel=$1; while(( getline < sel ) > 0 ){if ( $1 != ";ccc/'$ext'" ){avg = avg + $4;n++;}};avg = avg/n; printf("%s\n",avg)}'`
		echo "${sel}${inum}.${ext}" $average "${output_file}_${inum}.${ext}" | awk 'BEGIN{i=0}{sel=$1;cut=$2;out=$3;while(( getline < sel ) > 0){if ($1 != ";ccc/'$ext'" ){if($4 > cut){i++;printf(" %4d 2 %s %s\n",i,$3,$4)>> out; }}}}'
	else
		grep ";" corr_$inum.$ext > ${output_file}_${inum}.${ext}
		set num_lines = `grep -v ";" corr_$inum.$ext | wc | awk '{printf("%d",$1)}'`
		set keep_num = `echo $percent $num_lines | awk '{printf("%d",$2*$1/100)}'`
		grep -v ";" corr_$inum.$ext | sort -nk4 | tail -$keep_num >> ${output_file}_${inum}.${ext}
		$spider <<EOSc
doc/$ext
doc ren
${output_file}_${inum}
${output_file}_${inum}
en d
EOSc
	endif

@ i++
end

