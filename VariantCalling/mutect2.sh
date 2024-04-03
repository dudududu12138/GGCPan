#! /bin/bash

# data
sample=$1
chrid=$2
echo $chrid
normal=$(echo $sample | awk -F "." '{print $1}')
tumor=$(echo $sample | awk -F "." '{print $2}')
reference=your_reference
normal_bam=$normal/$normal.recal.bam
tumor_bam=$tumor/$tumor.recal.bam
pon=/data/known/somatic-hg38_1000g_pon.hg38.vcf.gz
resource=/data/known/somatic-hg38_af-only-gnomad.hg38.vcf.gz
res_dir=your_path
interval=/data/known/MYinterval_list

# GATK mutect2 pipeline
if [ ! -d $res_dir/$normal.$tumor ]; then
  mkdir $res_dir/$normal.$tumor
fi

# Step1: Detect raw variants
gatk Mutect2 \
  --java-options "-XX:ParallelGCThreads=3 -XX:ConcGCThreads=3 -Xmx8g" \
  -R $reference \
  -I $tumor_bam \
  -I $normal_bam \
  -tumor $tumor \
  -normal $normal \
  -L $interval/${chrid}.interval_list \
  -pon $pon \
  --germline-resource $resource \
  -O $res_dir/$normal.$tumor/${normal}.${tumor}_${chrid}.vcf.gz

# Step2: Filter the raw result
# GATK merge somatic variants of each chromosome
zcat ${sample}_chr1.vcf.gz | grep "^#" |grep -v "##contig" > ${sample}_merged.vcf
for i in $chrom_list ; do
  zcat ${sample}_${i}.vcf.gz | grep -v "^#" >>${sample}_merged.vcf
done

bcftools view ${sample}_merged.vcf -Oz -o ${sample}_merged.vcf.gz && rm ${sample}_merged.vcf
bcftools index -t ${sample}_merged.vcf.gz
cp ${sample}_chr1.vcf.gz.stats ${sample}_merged.vcf.gz.stats

# GATK GetPileupSummaries to summarize read support for a set number of known variant sites
gatk GetPileupSummaries \
  -I $tumor_bam \
  -V $known_dir/chr17_small_exac_common_3_grch38.vcf.gz \
  -L $known_dir/chr17_small_exac_common_3_grch38.vcf.gz \
  -O tumor_get_pileup_summaries.table

gatk GetPileupSummaries \
  -I $normal_bam \
  -V $known_dir/chr17_small_exac_common_3_grch38.vcf.gz \
  -L $known_dir/chr17_small_exac_common_3_grch38.vcf.gz \
  -O normal_get_pileup_summaries.table

# Estimate contamination
gatk CalculateContamination \
  -I tumor_get_pileup_summaries.table \
  -matched normal_get_pileup_summaries.table \
  -O calculate_contamination.table

# Apply filters
gatk FilterMutectCalls \
  -V ${sample}_merged.vcf.gz \
  -R ${known_dir}/hg38.fa \
  --contamination-table calculate_contamination.table \
  -O ${sample}_filtered.vcf.gz

# Filter
zgrep "^#" ${sample}_filtered.vcf.gz >${sample}_PASS.vcf
zgrep -v "^#" ${sample}_filtered.vcf.gz | awk '$7=="PASS"' >>${sample}_PASS.vcf
bcftools view -Oz -o ${sample}_PASS.vcf.gz ${sample}_PASS.vcf
bcftools index -t ${sample}_PASS.vcf.gz
