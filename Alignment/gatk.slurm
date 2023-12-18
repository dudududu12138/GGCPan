#!/bin/bash

#step 1. Mapping 'fastq' file to the reference by bwa:
echo -e "Job $SLURM_JOBID starts at $(date)." >>bwa.log
start=$(date +%s)
bwa mem -M -R "@RG\tID:$sample\tSM:$sample\tPL:illumina\tLB:bar\tPU:barcode" \
  -t 20 $reference $fastq_file1 $fastq_file2 >$sample.sam 2>bwa.log
end=$(date +%s)
cost=$((end - start))
echo -e "bwa kernel time $((cost / 60))min $((cost % 60))s.\n" >>bwa.log

start=$(date +%s)
samtools view -@ 20 -bS $sample.sam >$sample.bam &&
  rm $sample.sam
end=$(date +%s)
cost=$((end - start))
echo -e "sam2bam kernel time $((cost / 60))min $((cost % 60))s.\n" >>bwa.log

start=$(date +%s)
samtools sort -@ 20 -m 2G -o $sample.sorted.bam -O bam -T sorted $sample.bam &&
  rm $sample.bam
end=$(date +%s)
cost=$((end - start))
echo -e "sortbam kernel time $((cost / 60))min $((cost % 60))s.\n" >>bwa.log
samtools index -@20 $sample.sorted.bam

#step 2. Mark PCR duplications by gatk:
start=$(date +%s)
echo "Start MarkDuplicate at $(date)" >${sample}.gatk.log
gatk MarkDuplicates \
        -I $sample.sorted.bam \
        -O $sample.dedup.bam \
        -M $sample.metrics.txt \
        --TMP_DIR temp \
   && rm $sample.sorted.bam

end=$(date +%s)
cost=$((end - start))
echo -e "MarkDuplicates kernel time $((cost / 60))min $((cost % 60))s.\n" >>$sample.gatk.log

start=$(date +%s)
samtools index -@ $thread $sample.dedup.bam

end=$(date +%s)
cost=$((end - start))
echo -e "index kernel time $((cost / 60))min $((cost % 60))s.\n" >>${sample}.gatk.log

#step 3. Base quality score recalibration by gatk:
start=$(date +%s)
echo "Start BQSR at $(date)" >>${sample}.gatk.log
gatk BaseRecalibrator \
   -R $reference \
   -I $sample.dedup.bam \
   --known-sites dbsnp_146.hg38.vcf \
   --known-sites Mills_and_1000G_gold_standard.indels.hg38.vcf \
   -O ${sample}.recal_data.table

gatk ApplyBQSR \
   -R $reference \
   -I $sample.dedup.bam \
   -bqsr ${sample}.recal_data.table \
   -O $sample.recal.bam \
   && rm $sample.dedup.ba*

end=$(date +%s)
cost=$(( end - start ))
echo -e "BQSR kernel time $((cost/60))min $((cost%60))s.\n" >>${sample}.gatk.log
