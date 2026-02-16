This is the code to process the RNA-seq data from "Enzyme-enhanced RNA isolation from biofilm producing bacteria." Usage functions for each file are as follows.

* `processing_paired_reads.slurm` is used on the UVA RIVANNA HPC and is the main code to trim, QC, align, and generate counts from the raw reads files.
* `run_pipeline.sh` is the shell script submitted to the UVA HPC to parallelize the processing of the raw reads.
* `SMLT_differential_expression.Rmd` is the code used to produce all the figures from the processed counts data.
* `Genome/` Folder contains the annotated genome and files for the STAR aligner.

