#! /bin/bash

vg pack -t 6 -x index.xg -g $sample.gam -Q 5 -o $sample.pack
vg call -t 6 -a -s $sample -k $sample.pack index.xg >$sample.allsnarl.vcf && rm $sample.pack

