#! /bin/bash

#Step1 VG Giraffe mapping
echo -e "Job $SLURM_JOBID starts at $(date)." >alignment.log
start=$(date +%s)

vg giraffe -t 15 \
 -Z ${index}pan.sv370.giraffe.gbz \
 -m ${index}pan.sv370.min \
 -d ${index}pan.sv370.dist \
 -x ${index}pan.sv370.xg \
 -f $fastq_file1 \
 -f $fastq_file2 \
 -N ${sample} -R $sample \
 >${sample}.gam

end=$(date +%s)
cost=$((end - start))
echo -e "giraffe kernel time $((cost / 60))min $((cost % 60))s.\n" >>alignment.log

#Step2 VG Surject to bam (Optional)
echo -e "Job $SLURM_JOBID starts at $(date)." >alignment.log
start=$(date +%s)

vg surject -t 15 \
 -x ${index}pan.sv370.xg \
 -b -P -i  -N ${sample} -R $sample \
 ${sample}.gam >${sample}.bam 

end=$(date +%s)
cost=$((end - start))
echo -e "surject kernel time $((cost / 60))min $((cost % 60))s.\n" >>alignment.log
