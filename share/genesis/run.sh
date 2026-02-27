#!/bin/bash

####################################################################
# Script facilitates running multiple instances in the background
# Modify variables accordingly 
####################################################################

alertscript=~/alert.sh  # User created script to notify him/her a genesis was found!
instances=10            # Number of instances to run on this machine..
interval=50             # Number of seconds added to time upon nonce rollover; put the total number of instances to be run across all machines.
offset=0                # Offset so this batch of instances will avoid doing the same work as another batch (e.g. this very script [unmodified], run on 5 machines, would have offsets of 0, 10, 20, 30, 40).
time=699096905
timestamp="The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
value=50
bits=0x1d00ffff

mkdir ~/output
for (( i=${offset}; i<$((instances + offset)); i++ ))
do
        (python3 ~/genesis/genesis.py -i ${interval} -t $((time + i)) -z "${timestamp}" -v ${value} -b ${bits} > ~/output/out${i}; pkill python3; bash ${alertscript} ~/output/out${i}) &
done