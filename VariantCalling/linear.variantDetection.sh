#! /bin/bash

## detect SV with Manta
configManta.py --normalBam $normal_bam --tumorBam $tumor_bam --referenceFasta $reference --runDir $out/$sample/result 
$out/$sample/result/runWorkflow.py -m local -j 16

## detect SV with Svaba
$svaba run -t $bam -p 6 -D $known_indel -a $sample -G $reference

## detect SV with Delly
delly call -x $excl -o $normal.$tumor.bcf -g $reference $tumor_bam $normal_bam
printf "%s\tcontrol\n" $normal >> samples.tsv
printf "%s\ttumor" $tumor >> samples.tsv
delly filter -p -f somatic -o $normal.$tumor.somatic.bcf -s samples.tsv $normal.$tumor.bcf

## merge SVs from Manta,Svaba and Delly
$survivor merge vcf_files 1000 2 1 1 0 30 ${sample}.merged.vcf
