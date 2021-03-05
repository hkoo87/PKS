#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Annotation
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=20:00:00
#SBATCH --output=blast.%j.out
#SBATCH --error=blast.%j.err
#SBATCH --mail-type=ALL


source mgSNP.config.txt 


SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do
source activate prokka-1.14.0
prokka MEGAHIT-Bvul/PROKKA/${SAMPLE}-BvulAll-contigs.fasta --outdir MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA --cpus 0 --addgenes --metagenome --mincontiglen 1
conda deactivate

grep "eC_number=" MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA_*.gff | cut -f9| cut -f1,3 -d ';'|sed 's/ID=//g'|sed 's/;eC_number=/\t/g' > MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.ec

MinPath1.4.py -any MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.ec -map ec2kegg_final -report MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.report -details MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.detail

awk '{ if ($8 == 1) print $14}' MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.report > MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.report.minpath1

for i in $(awk '{print $1}' MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.report.minpath1); do curl -S http://rest.kegg.jp/find/pathway/$i>>MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel.minpath1; done

sed -i 's/path://g' MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel.minpath1 

awk '{print $0 "\t" "1"}' MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel.minpath1 > MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel2.minpath1

rm -rf MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel.minpath1

mv MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel2.minpath1 MEGAHIT-Bvul/PROKKA/${SAMPLE}-PROKKA/PROKKA-${SAMPLE}.kegg.reportLabel.minpath1

done

