#!/bin/bash

##############################################################
#EMAN2 loop script to output the particles after picking
#the micrographs pairs.
#the name of the micrographs pairs need to be with the same
#numbre [i] 
##############################################################

for i in {0001..0200}
do
    e2RCTboxer.py micrographs/Prp1_crylyUnTiltS_${i}.hdf micrographs/Prp1_crylyTiltS_${i}.hdf --boxsize=64 --write_boxes --write_ptcls --format=hdf --norm=normalize.edgemean
   
done
