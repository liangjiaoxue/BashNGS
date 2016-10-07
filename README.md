# BashNGS
Bash for NGS Analysis  

Here are some bash scripts to do NGS analysis. Generally, they are used to submit jobs to backend or queue on cluster


#FastqMerge
Merge fastq.gz files in one directory  
For each sample, there are four lanes (L001,L002,...), for each lane there are two read ends (R1 and R2).  
This script merge fastq files from four lanes into R1 and R2 respectively. 


#UnuiqueCount
Count uniquely mapped paired end reads in bam files under one directory.  

