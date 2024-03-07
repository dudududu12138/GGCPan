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
Reads aligned to linear references using `BWA MEM` and `GATK` pipeline.   
Reads aligened to graph-modeled pangenome using `vg giraffe`.
## Variant Calling
We used Manta, Delly,Svaba,Survivor,vg call and Mutect2 to detect SNPs,Indels and SVs.
