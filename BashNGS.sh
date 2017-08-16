
# Fastq counting
cd 
for file in *.fastq ; do 
sample=${file%.fastq}  
out=$sample"_out_num.txt"
wc -l $file >$out &
done


outfile="ReadNumber.tab"
cat *num.txt | while read line
do 
  a=($line)
  num=$((${a[0]}/4))
  printf ${a[1]}"\t"$num"\n" >>$outfile
done


## SAMBAMBA
cd /lustre1/reeves17/SNP717_2nd/06Hapcut/pac_sam
sambamba=/home/lxue/tool/sambamba/sambamba_v0.6.5
$sambamba merge -t 5 Pacbio_merge_new.bam *.sorted.bam &



# total length of fastq

cd 
for file in *.fastq; do
out=$file"_out.txt"
cat $file | awk 'BEGIN{sum=0;}{if(NR%4==2){sum+=length($0);}}END{print sum;}' >$out
done



# extract fasta with one ID
awk -v seq="Consensus_utg002307l" -v RS='>' '$1 == seq {print RS $0}' Pop717_racon_out_test.fasta  >Pop717_s1.fa




# zip and index vcf in worker shell files
cd 
master="Shell_master_zip.sh"
printf "#"'!'/bin/bash"\n" >$master
index=0
for file in *.vcf
do
  index=$(($index+1))
  sh_worker="run"$index"_"$file"_run.sh"
  printf "#"'!'/bin/bash"\n" >$sh_worker
  file2=$file".gz"
  printf "/usr/local/apps/samtools/1.2/bin/bgzip $file\n" >>$sh_worker
  printf "/usr/local/apps/samtools/1.2/bin/tabix -p vcf $file2\n" >>$sh_worker
  printf "./"$sh_worker"\n" >>$master
done


chmod 777 *.sh
./Shell_master_zip.sh


##########################
## generat long shell file
cd /lustre1/lxue/SNP717v2/07Phasing/sort
master="Shell_master_sort_vcf.sh"
printf "#"'!'/bin/bash"\n" >$master
index=0
for file in ../phased/*.vcf.gz
do
  shortname=${file##*/}
  sample=${shortname%%.vcf.gz}
  out=$sample"_sort.vcf"
  index=$(($index+1))
  sh_worker="run"$index"_"$out"_run.sh"
  printf "qsub "$sh_worker"\n" >>$master
  printf "#"'!'/bin/bash"\n" >$sh_worker
  printf "#PBS -N vcf_sort\n" >>$sh_worker
  printf "#PBS -q batch\n" >>$sh_worker 
  printf "#PBS -l nodes=1:ppn=1:HIGHMEM\n" >>$sh_worker 
  printf "#PBS -l walltime=10:00:00\n" >>$sh_worker 
  printf "cd /lustre1/lxue/SNP717v2/07Phasing/sort" >>$sh_worker 
  printf "module load python/3.4.3" >>$sh_worker  
  printf "python VCF_Haplo_sorting_wo_merge.py "$file" \\" >>$sh_worker  
  printf "\n" >>$sh_worker  
  printf "  ../Potra01b_merge_out.delta_FX.vcf  ../Palba_ref_v3_PASS.vcf  "$out >>$sh_worker  
done




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


#### version with two layers of folders
for folder in Sample_*
do
echo "Sample ID "$folder
out1="/sdb/01fastq/"$folder"_R1.fq.gz"
out2="/sdb/01fastq/"$folder"_R2.fq.gz"
echo "Input set1 "$out1
echo "Input set2 "$out2
cat ./$folder/*R1*.gz >$out1 
cat ./$folder/*R2*.gz >$out2 
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

