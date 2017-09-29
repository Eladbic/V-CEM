#!/bin/tcsh -f
# multireference alignment and classification				###  ### 
# randomly geneterated first round references				#  # #  #
#									###  ###
# Edit the variables in the VARIABLES section to match your data	#  # #
# run using command : ./mra.sc > mra.log &				###  #
#
#
# uses proceedures:
# alqmd.mra
# center.mra
# combat.mra



###########
# VARIABLES
###########

set part_nums = 6542			# The number of particles in the stack
set image_size = 128			# The size of the image (assumed squared)
set outer_radius = 50			# The size of the outer radius for alignment mask
set inner_radius = 1			# The size of the inner radius for alignment mask
set factors_or_raw = 1			# If factors_or_raw = 1 classify based on raw data
					# If factors_or_raw = 2 classify based on factors from Principal Component Analysis

set num_of_factors = 10			# If factors_or_raw = 2, set the number of factors to use
set num_of_groups = 20			# Set the number of groups to align particles into
set num_of_iterations = 10		# The number of times we should iterate alignment procedure
set ext = "ntc"				# the data extension for your project (ie file_0001.EXT, EXT is extension)
set input_stack	= "../Stacks/sp3x_spider"	# The name of the input stack to be aligned

###########
# PROGRAM - no edits
###########

# spimple program, output the data to the b03.mra batch file
# then run it

# if people have put on the .ext to the stack name lets kill it AHHH HA HA HA

set stack_name = `echo $input_stack | awk -F "/" '{printf("%s",$NF)}' | awk -F "." '{printf("%s",$1)}'`
set stack_path = `echo $input_stack | awk -F "/" 'BEGIN{i=1}{while( i < NF){printf("%s/",$i); i++}}'`
set real_stack = `echo $stack_path$stack_name`

# output step
printf "\n\nOutputting data and creating b03.mra\n\n"


sed "s/PART/$part_nums/g" b03template.mra | sed "s/SIZE/$image_size/g" | sed "s/OUT_RAD/$outer_radius/g" | sed "s/IN_RAD/$inner_radius/g" | sed "s/RAW/$factors_or_raw/g" | sed "s/FACTORS/$num_of_factors/" | sed "s/GROUP/$num_of_groups/" | sed "s/ITER/$num_of_iterations/" | sed "s;INPUT;$real_stack;" > b03.mra

printf "DONE"

# run program
printf "\n\nRunning Spider Now...\n\n"

#set OS = `echo $HOSTTYPE`
#if ($OS == "i386-linux") set spider   = "/programs/i386-linux/spider/15.06/spider/bin/spider"
#if ($OS == "iris4d") set spider   = "/programs/iris4d/spider/8.02/spider/bin/spider5"
#set spider = "/programs/i386-linux/spider/15.06/spider/bin/spider"
set spider = "/programs/i386-linux/spider/8.02/bin/spider"


$spider <<EOSc 
mra/$ext 
b03
en d
EOSc

printf "\nDONE"

# run order.sc for each cluster
printf "\n\nRunnung order.sc for ech cluster\n"

chmod ugo+x order.sc

set num_plus = `echo $num_of_iterations | awk '{printf("%d",$1+1)}'`
set i = 1
while ($i <= $num_plus)
set current = `echo $i | awk '{printf("%02d",$1)}'`
cd cluster$current
../order.sc
cd ../
printf "\nCluster$current ordered\n"
@ i ++
end

printf "\nDONE"
# thats it!
exit()
