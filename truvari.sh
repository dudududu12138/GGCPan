#! /bin/bash

truvari bench -f $reference \
 -c $call \
 -b $base \
 -o result \
 --refdist 1000 --pctsim 0  --pctsize 0.7 --passonly 


