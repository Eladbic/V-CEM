#!/bin/csh -f

###############################
# script to make stack file for spider
# change stackname
# the number in the name should be the number of particles
#
###############################
set stackname = "Prp19_5800"
foreach i (*hed)
proc2d $i $stackname
end
