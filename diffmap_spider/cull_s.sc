#!/bin/csh -f
#
# cull "bad" particles from previously windowed particles, using pick
# files generated with web's category command
# basically, loop through all the micrographs, counting particles, then
# forming a list of good particles (using mergeneg.awk).  set up a spider
# template and then dump all the good windowed images to an image stack.
#
# Implentation: DEC or SGI
# Last updated: Thu Apr 11 14:47:19 EDT 2002

###########
# VARIABLES
###########

set image_directory  = "win"	# directory where windowed images are 
set img_file_root  = "win_"	# file name root of windowed images
set extension = "vac"		# your data extension
set badname  = "baduntilt_"	# the name of the file where the bad image numbers are placed
set first = 1			# first image to work on
set last = 1			# last image to work on
set stack_start_number = 1	# the location in the stack to start placing the new images
set box_size = 320		# the box size that you used to window the particles

##########
# PROGRAM - no edits
##########

# set up spider for OS
#set OS = `echo $HOSTTYPE`
#if ($OS == "i386-linux") set spider   = "/programs/i386-linux/spider/8.02/bin/spider"
#if ($OS == "iris4d") set spider   = "/programs/iris4d/spider/8.02/spider/bin/spider5"
set spider = "/programs/i386-linux/spider/8.02/bin/spider"

set template = "b02template.stk"
set outname  = "good"

# the outer loop - micrograph number
@ i = ${first}
set stack = $stack_start_number
while( $i <= ${last} )

# figure the expanded micrograph number and number of particles per micrograph
        set imgnum = `echo ${i} | awk '{printf("%04d\n", $1)}'`

### mini loop to determin number of images in directory
                set k = 1
                set top_num = 99999999
                while ($k < = $top_num )
                if ($k <= 0 ) echo "No particles... Skipping Directory"
                if ($k <= 0 ) goto skip_mark1
                set num = `echo $k | awk '{printf("%05d",$1)}'`
                if (-e $image_directory/$imgnum/$img_file_root$num.$extension ) then 
                @ k ++
                else
                @ k --
                set prtnum = $k
                set top_num = 1 
                endif
                end

	echo -n "micrograph number ${imgnum} contains ${prtnum} particles"

# If a badname file exists then merge and negate, otherwise create a good file with all particles

	if (-e ${image_directory}/${imgnum}/${badname}${imgnum}.${extension} ) then 
# merge and negate the bad tilted and untilted particle lists
		echo "${image_directory}/${imgnum}/${badname}${imgnum}.${extension}" \
			 "${image_directory}/${imgnum}/${outname}${imgnum}.${extension}" \
		 	"${prtnum}" | awk -f mergeneg.awk

	else
# make all good file
		echo "${image_directory}/${imgnum}/${outname}${imgnum}.${extension}" "${prtnum}" "${extension}" | awk -f only_good.awk
	endif

# determine the number of "good" particles
	set godnum = `grep -v '^ ;' ${image_directory}/${imgnum}/${outname}${imgnum}.${extension} | tail -1 | awk '{printf("%04d\n", $1)}'`
	echo " of which ${godnum} are good."
	@ stkend = ${stack} + ${godnum} - 1
	echo " NOTE: micrograph ${imgnum} runs from stack location ${stack} to ${stkend}"

# make stacks dir
if (! -e ../stacks/ ) mkdir ../stacks

# modify the spider template, then launch the windowing proceedure
	sed "s/IMGNUM/${imgnum}/g" ${template} | sed "s/PRTNUM/${godnum}/" | \
		sed "s/STKLOC/${stack}/" | sed "s/SRCLOC/${image_directory}/g" | \
		sed "s/SRC2LOC/${img_file_root}/g" > b02.stk
	${spider} << EOSc
stk/${extension}
b02
en
EOSc

# clean up and increment the loop counter
	rm -f b02.stk b02X.stk
	@ stack += ${godnum}
	
# skip to here if no particles found
skip_mark1:
	@ i++

end

# normalize the stack
sed "s/SIZE/$box_size/" b03template.nrm | sed "s/PART/$stkend/" | sed "s;DIREC;../stacks/;" | sed "s/STACK/win/" |  sed "s/OUT/norm_win/" | sed "s/START/$stack_start_number/" > b03.nrm

${spider} << EOSc
nrm/$extension
b03
en
EOSc

rm -f b03X.nrm LOG.*
# done have a nice day :)
