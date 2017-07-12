#!/bin/bash

for i in  {842.. 999}
do
    sxcpy.py ../transfer/Cdc5TAP2_0${i}.dm3 splice_0${i}.hdf
done
