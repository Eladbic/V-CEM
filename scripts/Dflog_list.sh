#!/bin/bash

#################################################################
# script to get micrographs with bad frames (blank)
#output will give mico # and first frames # that blank
#
# run script: Dflog_list.sh > <output_file>
# Elad Binshtein 012916 V1
############Variables############################################


#################################################################


  
for i in *Full.log
do 

awk '!/^$/{
   if  ($2<-500)
   {print $1, FILENAME;exit}}' ${i}
    
 
   
done



