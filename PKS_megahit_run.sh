#!/bin/bash
#
#SBATCH --mail-type=ALL                     
#
#SBATCH --job-name=Megahit                   
#
#SBATCH -n 8                                
#SBATCH --mem-per-cpu=80000                  
#SBATCH -t 0-30:00:00                       
#SBATCH --share
#SBATCH --partition=medium
#
#SBATCH --error=%jmegahit.%N.err.txt             
#SBATCH --output=%jmegahit.%N.out.txt            
#
source mgSNP.config.txt 
mkdir MEGAHIT-Bvul/PROKKA 

source activate MEGAHIT

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do
megahit -r MEGAHIT-Bvul/${SAMPLE}_BvulAll.fastq -o MEGAHIT-Bvul/${SAMPLE}-BvulAll-contigs
cp MEGAHIT-Bvul/${SAMPLE}-BvulAll-contigs/final.contigs.fa MEGAHIT-Bvul/PROKKA/${SAMPLE}-BvulAll-contigs.fasta 
done

source deactivate

