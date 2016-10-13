
# FastqMerge

# Merge fastq.gz files in one directory
# For each sample, there are four lanes (L001,L002,...), for each lane there are two read ends (R1 and R2).
# This script merge fastq files from four lanes into R1 and R2 respectively. 

cd fastq_dir
ls -a | grep _L001_R1_001.fastq.gz | while read -r line ; do
   echo "Processing file $line"
   sample=${line%_L001_R1_001.fastq.gz}   
   echo "Processing sample $sample"
   cat $sample*"_R1_001.fastq.gz" >$sample"_R1.fq.gz"
   cat $sample*"_R2_001.fastq.gz" >$sample"_R2.fq.gz"
done

#UnuiqueCount
# Count uniquely mapped  reads in bam files under one directory

# paired end reads
cd bam_dir
for file in *.bam; do
fileout="$file""_out.txt"
echo "$fileout"
samtools view -F 0x4 $file | cut -f 1 | sort | uniq | wc -l > $fileout
done

# singe end reads
cd bam_dir
for file in *.bam; do
fileout="$file""_out.txt"
echo "$fileout"
samtools view -F 0x904 -c $file > $fileout
done

#####################################################################
## generate shell file
cd file_dir
master="Shell_master.sh"
echo "#"'!'/bin/bash >$master
for file in *.tab; do
fileout=$file"_out.txt"
sh_worker=$file"_run.sh"
echo "#"'!'/bin/bash >$sh_worker
echo "wc -l $file >$fileout" >>$sh_worker
echo "qsub rcc-30d "$sh_worker >>$master
done









