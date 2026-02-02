set -euo pipefail # if something fails the script stops

# Initialize pipeline log 
pipeline_log="log/pipeline.log"
echo "Pipeline run: $(date)" > "$pipeline_log" # >> inestead of > for appendind and not overwriting

#Download all the files specified in data/filenames
URLS_FASTQ=data/urls
while read url
do
    bash scripts/download.sh $url data
done < $URLS_FASTQ

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
URL_FASTA=https://masterbioinformatica.com/decont/contaminants.fasta.gz
bash scripts/download.sh $URL_FASTA res yes "snRNA|small nuclear" 

# Index the contaminants file
bash scripts/index.sh res/contaminants_filtered.fasta res/contaminants_idx

#Merge, trim. align and append logs
for sid in $(ls data/*.fastq.gz | cut -d"-" -f1 | sed "s:data/::" | sort | uniq) 
do
    # Merge the samples replicates into a single one
    bash scripts/merge_fastqs.sh data out/merged $sid

    #Trim(cutadapt) + Align(STAR) + LOGs
    merged_file="out/merged/${sid}.fastq.gz"
    bash scripts/trimme_align.sh "$merged_file" $sid


    # Append cutadapt and STAR summaries to a single log file
    # - cutadapt: total reads and reads with adapters
    # - STAR: % uniquely mapped, % multiple loci, % too many loci
    # Use grep to extract these lines

    # --- Append cutadapt info ---
    echo -e "\n[Sample: $sid] CUTADAPT summary:" >> "$pipeline_log"
    grep "Total reads processed\|Reads with adapters" "log/cutadapt/${sid}.log" >> "$pipeline_log"
    
    # --- Append STAR info ---
    echo -e "\n[Sample: $sid] STAR alignment summary:" >> "$pipeline_log"
    grep -E "Uniquely mapped reads %|% of reads mapped to multiple loci|% of reads mapped to too many loci" \
        "out/star/${sid}/Log.final.out" >> "$pipeline_log"
done
