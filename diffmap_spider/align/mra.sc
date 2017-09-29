#!/bin/tcsh -f
# true multireference alignment								###  ###
# user must specify the references usually in input_references/refXXX.ext		#  # #  #
# either use the auto copy feature or manually copy all input refs to directory		###  ###
# edit all the variables in the VARIABLES section					#  # #
# use command: ./msa.sc >msa.log &							###  #
#
# uses proceedures:
# alqr.mra
# center.mra
# combat.mra



#############
# VARIABLES
#############

set input_stack = "../../stacks/norm_win"		# The root name of the stack to be aligned
set extension = "vac"				# The data extension of the project
set num_parts = 2				# Number of images in stack
set image_size = 120				# Box size of the particles
set outer_radius = 50				# Outer radius for alignment mask
set inner_radius = 1				# Inner radius for alignment mask
set search_range = 5 				# number of pixels in any direction images can be 
						# shifted to align them
set num_of_groups = 2				# The number of groups you have designated it to 
						# align to (each needs a reference image!)
set num_of_iterations = 1			# Number of times to repeat the alignment step

####
# Auto copy of input refs:  For each group you need a reference image located in a directory 
# "input_references/" there is a utility built into this script to automatically copy these 
# images into the proper location. To turn this utility on set on_off below to 1 for "on" 
# or 2 for "off".  Set the remaining variables. Numbers in "set imgs = " must be separated 
# by commas for it to work, and there must be 1 image for each group!.  If you want to specifiy 
# a location from classorder and have the script translate that into a image number set classorder 
# to "y"
###

set on_off = 2					# 1 for auto copy "on" ; 2 for auto_copy "off"
set avgs_dir = "../make_stack/win/0001/win_00003.apc"	# the location of the averages to be copied and 
						# classorder.ext document
set imgs = "3,4,8"			# image numbers to copy over (or if crossreferencing 
						# classsorder - then classorder number)
set classorder = "y"				# answer is whether or not to crossrefrence 
						# classorder.ext or not ( y = cross ref, n = no!)

###########
# PROGRAM - no edits
###########

###
# Check variables setting and die if problems exist
###

set errors = 0
if (($classorder != y ) && ($classorder != n )) then
	printf "\nbad classorder answer\n"
	@ errors ++	
endif

if (($on_off != 1 ) && ($on_off != 2 )) then
	printf "\nbad on_off answer\n"
	@ errors ++	
endif

if ($on_off == 1 ) then
# do the auto copy errors
	set num_images = `echo $imgs | awk -F "," '{printf("%d",NF)}'`
	if ($num_images != $num_of_groups) then
		printf "\nNumber of entries in 'set imgs' does not match number of groups\n"
		@ errors ++	
	endif

	if (! -e $avgs_dir) then
		printf "\nAverages directory does not exist\n"
               @ errors ++ 
        endif
	
	if (($classorder == y ) && (! -e $avgs_dir/classorder.$extension)) then
                printf "\nClassorder document does not exist\n"
               @ errors ++ 
        endif
endif


# if people have put on the .ext to the stack name lets kill it AHHH HA HA HA

set stack_name = `echo $input_stack | awk -F "/" '{printf("%s",$NF)}' | awk -F "." '{printf("%s",$1)}'`
set stack_path = `echo $input_stack | awk -F "/" 'BEGIN{i=1}{while( i < NF){printf("%s/",$i); i++}}'`
set real_stack = `echo $stack_path$stack_name`

if (! -e $real_stack.$extension ) then
	printf "\nStack does not exist\n"
	@ errors ++	
endif

if ($errors >= 1 ) then
printf "\n\nYou have $errors errors, clean them up and rerun\n\n"
exit()
endif

###
# if auto copy is on do it
###

if($on_off == 1 ) then
	set ext = $extension
	if (! -e input_references/ ) mkdir input_references
	if ($classorder == n ) then
		@ i = 1
		while ($i <= $num_of_groups)
			set imgnum = `echo $imgs | awk -F "," '{printf("%03d\n",$'$i')}'`
			set refnum = ` echo $i | awk '{printf("%03d", $1)}'`
			cp $avgs_dir/avg$imgnum.$ext input_references/ref$refnum.$ext
			@ i ++
		end
	else
		@ i = 1
		while ($i <= $num_of_groups)
			set startnum = `echo $imgs | awk -F "," '{printf("%04d\n",$'$i')}'`
			set imgnum = `grep $startnum $avgs_dir/classorder.$ext | awk '{printf("%03d\n",$3)}'`
			set refnum = ` echo $i | awk '{printf("%03d", $1)}'`
			cp $avgs_dir/avg$imgnum.$ext input_references/ref$refnum.$ext
			@ i ++
		end
	endif
endif

##
# output step
##

printf "\n\nOutputting data and creating b03.mra\n\n"


sed "s/PART/$num_parts/g" b03template.mra | sed "s/SIZE/$image_size/g" | sed "s/OUT_RAD/$outer_radius/g" | sed "s/IN_RAD/$inner_radius/g" | sed "s/RANGE/$search_range/g" | sed "s/GROUP/$num_of_groups/" | sed "s/ITER/$num_of_iterations/" | sed "s;INPUT;$real_stack;" > b03.mra

printf "DONE"

##
# Spider step
##

printf "\n\nRunning Spider Now...\n\n"

#set OS = `echo $HOSTTYPE`
#if ($OS == "i386-linux") set spider   = "/programs/i386-linux/spider/8.02/bin/spider"
#if ($OS == "iris4d") set spider   = "/programs/iris4d/spider/8.02/spider/bin/spider5"
set spider = "/programs/i386-linux/spider/8.02/bin/spider"

$spider <<EOSc
mra/$extension
b03
en d
EOSc

printf "\nDONE"

# thats it!
exit()
