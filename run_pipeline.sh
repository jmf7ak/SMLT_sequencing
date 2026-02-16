#!/bin/bash



FASTQ_DIR="/scratch/jmf7ak/Sami/Sami_Illumina_RNA_Reads"

GENOME_INDEX_DIR='/scratch/jmf7ak/Sami'

ANNOTATION="/scratch/jmf7ak/Sami/PA14_modified.gtf"

OUTPUT_DIR="/scratch/jmf7ak/Sami/outputs_trimmed"

SCRIPTS_DIR='/scratch/jmf7ak/Sami'



mkdir -p ${OUTPUT_DIR}

mkdir -p logs



for R1 in ${FASTQ_DIR}/*_R1_001.fastq.gz; do

    SAMPLE=$(basename $R1 _R1_001.fastq.gz)



    echo "Submitting job for $SAMPLE..."



    sbatch ${SCRIPTS_DIR}/processing_paired_reads.slurm $SAMPLE $FASTQ_DIR $GENOME_INDEX_DIR $ANNOTATION $OUTPUT_DIR

done
