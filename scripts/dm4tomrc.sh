#!/bin/bash
# this scrip is to convert dm4 files to mrc


for i in {0003..0034}
do
    dm2mrc TcdA_ph5_300kV_${i}.dm4 TcdA_ph5_300kV_${i}.mrc
done
