cd fastq_dire


ls -a | grep _L001_R1_001.fastq.gz | while read -r line ; do
   echo "Processing file $line"
   y=${line%_L001_R1_001.fastq.gz}
   sample=${y##*/}
   echo "Processing sample $sample"
   cat $sample*"_R1_001.fastq.gz" >$sample"_R1.fq.gz"
   cat $sample*"_R2_001.fastq.gz" >$sample"_R2.fq.gz"
done
