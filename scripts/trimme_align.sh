if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <MERGED_SID_FASTQ> <SID>"
    echo "  MERGED_SID_FASTQ   : the filepath to the merged fastq for a sample (mandatory)"
    echo "  SID                : Sample ID (mandatory)"
    echo "Exiting program..."
    exit 1
fi

MERGED_SID_FASTQ=$1
SID=$2

# Define directories
cutadapt_dir="out/cutadapt"
cutadapt_log_dir="log/cutadapt"
star_sid_dir="out/star/${SID}/"

# Ensure the directories exist
mkdir -p "$cutadapt_dir" "$star_sid_dir" "$cutadapt_log_dir"

# Define trimmed/log files
trimmed_file="$cutadapt_dir/${SID}.trimmed.fastq.gz"
log_file="${cutadapt_log_dir}/${SID}.log"

echo 

# Run cutadapt for all merged files
if [ ! -f "$trimmed_file" ]
then 
    echo "Running cutadapt for $SID..."
        cutadapt -m 18 \
        -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o "$trimmed_file" "$MERGED_SID_FASTQ" > "$log_file" 2>&1
    echo "Trimmed file generated:$trimmed_file, saved in $cutadapt_dir."

else
    echo "Trimmed file $trimmed_file already exists, skipping cutadapt."
fi
echo


# Run STAR for all trimmed files
if [ ! -f "${star_sid_dir}/Unmapped.out.mate1" ]
then 
    echo "Running STAR alignment..."
    STAR --runThreadN 4 \
        --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx \
        --readFilesIn "$trimmed_file" \
        --readFilesCommand zcat \
        --outFileNamePrefix "$star_sid_dir"
    echo "Alignment successfully processed for $SID. Saved in $star_sid_dir."
else
    echo "STAR output for $SID already exists, skipping alignment."
fi
