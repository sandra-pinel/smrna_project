# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
# The directory containing the samples is indicated by the first argument ($1).


# Check for required arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
    echo "Usage: $0 <FASTQ_DIR> <OUT_DIR> <SID>"
    echo "  FASTQ_DIR : Directory containing source FASTQ files (mandatory)"
    echo "  OUT_DIR   : Destination directory for merged file (mandatory)"
    echo "  SID       : Sample ID (mandatory)"
    echo "Exiting program..."
    exit 1
fi

FASTQ_DIR=$1
OUT_DIR=$2
SID=$3

# Create the output directory if it doesn't exist
mkdir -p $OUT_DIR

# Define the output dir with the merged filename
merged_filepath="${OUT_DIR}/${SID}.fastq.gz"

echo 

if [ ! -f "$merged_filepath" ]
then
    echo "Merging files for sample $SID..."
    # Concatenate all technical replicates starting with the Sample ID
    cat "${FASTQ_DIR}/${SID}"*.fastq.gz > "$merged_filepath"
    echo "Files for $SID merged into $merged_filepath"
    echo
else
    echo "Merged file for $SID already exists, skipping merging."
fi





