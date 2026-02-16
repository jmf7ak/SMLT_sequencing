#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH -t 2:00:00
#SBATCH --mem=150000
#SBATCH --account=CSBLRivanna
#SBATCH --partition=standard
# Load modules (update module names for your system)


module load fastqc
module load star
module load bioconda/py3.10   # featureCounts
module load samtools

# Variables from master script

SAMPLE=$1
FASTQ_DIR=$2
GENOME_INDEX_DIR=$3   # STAR index directory
ANNOTATION=$4         # GTF file
OUTPUT_DIR=$5

# Input files
R1="${FASTQ_DIR}/${SAMPLE}_R1_001.fastq.gz"
R2="${FASTQ_DIR}/${SAMPLE}_R2_001.fastq.gz"

# Output folders
TRIM_DIR="${OUTPUT_DIR}/${SAMPLE}/trimmed"
QC_DIR="${OUTPUT_DIR}/${SAMPLE}/qc"
ALIGN_DIR="${OUTPUT_DIR}/${SAMPLE}/aligned"
COUNT_DIR="${OUTPUT_DIR}/${SAMPLE}/counts"
mkdir -p $TRIM_DIR $QC_DIR $ALIGN_DIR $COUNT_DIR
echo "Processing sample: $SAMPLE"

#####################################

# 1. Trim and QC (fastp + FastQC)

#####################################

fastp -i $R1 -I $R2 \
    -o ${TRIM_DIR}/${SAMPLE}_R1.trimmed.fastq.gz \
    -O ${TRIM_DIR}/${SAMPLE}_R2.trimmed.fastq.gz \
    --detect_adapter_for_pe \
    --thread 8 \
    --html ${QC_DIR}/${SAMPLE}_fastp.html \
    --json ${QC_DIR}/${SAMPLE}_fastp.json


fastqc ${TRIM_DIR}/${SAMPLE}_R1.trimmed.fastq.gz \
	${TRIM_DIR}/${SAMPLE}_R2.trimmed.fastq.gz -o $QC_DIR  --threads 8

#####################################

# 2. Alignment with STAR

#####################################

STAR --runThreadN 8 \
    --genomeDir ${GENOME_INDEX_DIR} \
    --readFilesIn ${TRIM_DIR}/${SAMPLE}_R1.trimmed.fastq.gz ${TRIM_DIR}/${SAMPLE}_R2.trimmed.fastq.gz \
    --readFilesCommand zcat \
    --outFileNamePrefix ${ALIGN_DIR}/${SAMPLE}_ \
    --outSAMtype BAM SortedByCoordinate \
    --limitBAMsortRAM 1507636195

#####################################

# 3. Index the BAM file (optional but good)

#####################################

samtools index ${ALIGN_DIR}/${SAMPLE}_Aligned.sortedByCoord.out.bam

#####################################

# 4. Counting with featureCounts

#####################################

featureCounts -T 8 \
    -a ${ANNOTATION} \
    -t CDS \
    -p \
    -g locus_tag \
    -F GTF \
    -o ${COUNT_DIR}/${SAMPLE}_counts.txt \
    ${ALIGN_DIR}/${SAMPLE}_Aligned.sortedByCoord.out.bam

echo "Sample $SAMPLE finished!"
