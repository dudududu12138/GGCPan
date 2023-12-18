#! /bin/bash

## align the contigs to reference
minimap2 -cx asm10 $ref ${sample}.500bp.contig.gz -t 4 --cs \
 | sort -k6,6 -k8,8n \
 >${sample}.srt.paf      

## detect variants from alignment result
k8 ${paftools} call \
 -f $ref -L500 -l500 -s $sample \
 ${sample}.srt.paf \
 >${sample}.vcf

## filter variant result
python minimap2.filter.py $sample

## compress
bcftools view -Oz -o ${sample}.vcf.gz ${sample}.vcf
bcftools index -t ${sample}.vcf.gz

## contruct graph-modeled pangenome
vg autoindex --workflow giraffe -r $ref -v $vcf -t $t -p index
vg convert -x index.giraffe.gbz -t $t >index.xg

