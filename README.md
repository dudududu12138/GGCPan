# GGCPan: A graph-modeled gastric cancer pangenome
## Introduction
We introduced a graph-based pangenome called GGCPan as a reference for gastric cancer, and systematically compared the results with those traditional genomics studies using the human reference genome or a linear pangenome as the references.
## GGCPan Construction
```
bash construct.sh
```
## Alignment
Reads aligned to linear references using `BWA` and GATK pipeline.   
Reads aligened to graph-modeled pangenome using VG Giraffe.
