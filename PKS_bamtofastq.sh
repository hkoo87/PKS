#!/bin/bash
#
#SBATCH --mail-type=ALL                     
#
#SBATCH --job-name=bamtofastq                   
#
#SBATCH -n 5                                
#SBATCH --mem-per-cpu=8000                  
#SBATCH -t 0-20:00:00                       
#SBATCH --share
#SBATCH --partition=medium
#
#SBATCH --error=%j.%N.err.txt             
#SBATCH --output=%j.%N.out.txt            

module load BEDTools/2.26.0-foss-2016a
module load FASTX-Toolkit

source mgSNP.config.txt 

mkdir MEGAHIT-Bvul  #change the "Bvul", if different species is selected.

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do

#change "Bacteroides_vulgatus" to other species, if necessary. Then, BvulAll also needs to be changed. 
samtools view -b ${GATK_STEPS}/${SAMPLE}_realigned.bam "Bacteroides_vulgatus" > ${GATK_STEPS}/${SAMPLE}_BvulAll.bam
samtools sort ${GATK_STEPS}/${SAMPLE}_BvulAll.bam ${GATK_STEPS}/${SAMPLE}_BvulAll_sorted
samtools index ${GATK_STEPS}/${SAMPLE}_BvulAll_sorted.bam
mv ${GATK_STEPS}/${SAMPLE}_BvulAll_sorted.bam ${GATK_STEPS}/${SAMPLE}_BvulAll.bam
mv ${GATK_STEPS}/${SAMPLE}_BvulAll_sorted.bam.bai ${GATK_STEPS}/${SAMPLE}_BvulAll_sorted.bai

bedtools bamtofastq -i ${GATK_STEPS}/${SAMPLE}_BvulAll.bam -fq ${GATK_STEPS}/${SAMPLE}_BvulAll.fastq


cp ${GATK_STEPS}/${SAMPLE}_BvulAll.fastq MEGAHIT-Bvul
done

