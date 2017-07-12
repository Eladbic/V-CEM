#!/bin/bash

for i in {0001..0200}
do
    e2proc2d.py Prp1_121113_${i}.hdf Prp1_121113S_${i}.hdf --meanshrink=2
done
