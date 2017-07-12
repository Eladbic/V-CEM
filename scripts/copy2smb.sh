#!/bin/bash

smbclient //10.119.16.241/mohilab/ -N ## IP an share name of the smb (-N=no pw)

do
cd 15_041116_Cdc5TAP ## dir to copy

put *mrc ## file name to copy

exit
