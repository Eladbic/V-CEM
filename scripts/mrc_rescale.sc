#!/bin/csh -f 									
# 			
# script to rescale the mrc file, and reverse the contrast:
#	y = -x + 255 	
# 
# The output is still mrc file, and both original and contrast 
# reversed mrc are kept, for imagic & frealign.
# 
# yifan cheng - Fri Nov  1 09:48:55 EST 2002
# modified by Melanie Ohi Jan 9 2003
#


############
# VARIABLES
############

set first = 1  			# first image number to work on
set last  = 203  			# Last image number to work on
set ostart = 1 			# number of first converted image
set mrcroot = "1832nta_amphi_dialy"			# root name of big mrc file
set mrctail = ".mrc"			# tail of big mrc file
set fileroot = "1832nta_amphi_dialy_S_"			# root of output small mrc file
set filetail = ".mrc"			# tail of output small mrc file
set scale = 2				# reduction factor
set mel = 1

##########
# Program - no edits
##########


@ i = ${first}

set mrcmid = ".mrc"

while( ${i} <= ${last} )

# calculate the current image number
set onum = `echo ${i} | awk '{printf("%04d\n", $1)}'`
set fnum = `echo ${ostart} | awk '{printf("%04d\n", $1)}'`

/programs/i386-linux/mrc/13.02.2001/image2000/bin/label.exe << EOSc
${mrcroot}${onum}${mrctail}
4
${fileroot}${fnum}${mrcmid}
${scale} ${scale} ${mel}
EOSc

#/programs/i386-linux/mrc/13.02.2001/image2000/bin/label.exe  << EOSc
#${mrcroot}${fnum}${mrcmid}
#2
#${mrcroot}${onum}${filetail}
#-1 255
#0
#EOSc

@ i++
@ ostart++

end


