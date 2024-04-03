# GGCPan: A graph-modeled gastric cancer pangenome
## Introduction
We introduced a graph-based pangenome called GGCPan as a reference for gastric cancer, and systematically compared the results with those traditional genomics studies using the human reference genome or a linear pangenome as the references. This is our construction method and the analysis pipeline.
## GGCPan Construction
* step1：Align assembled contigs(>500bp) to GRCh38 using minimap2.
* step2：Detect variants using paftools.js and filter the small variants and variants with quality <= 60.
* step3：Embed variants to GRCh38 using vg toolkit.
##### step1,2,3 are included in the following construct.sh file, which can be run to generate the graph-modeled pangenome.
```
bash construct.sh
```
## Alignment
#### Reads aligned to linear references using `BWA MEM` and `GATK` pipeline.   
* We firstly align the raw reads to references with BWA MEM,then mark duplications and adjust the base quality with GATK BQSR.
* The codes are stored in `Alignment/gatk.slurm`
#### Reads aligened to graph-modeled pangenome using `vg giraffe`.
* The raw reads are aligned to graph-modeled reference with `vg giraffe`. The codes are stored in `Alignment/graph.alignment.sh`.  
* To detect snps and indels from graph-modeled pangenome,we convert the format of graph alignment result(.gam) to linear alignment format(.bam).
## Variant Calling
#### SNPs and Indels
* We used `GATK Mutect2` to detect SNPs and Indels. The coded are stored in `VariantCalling/mutect2.sh`.
#### Structural vatiants
* We used `Manta`, `Delly`,`Svaba`,`Survivor` to detect SVs based on linear references. We used `vg call` to detect SVs based on graph-modeled references.  
* The codes are stored in `VariantCalling/linear.variantDetection.sh` and `VariantCalling/graph.variantDetection.sh`
