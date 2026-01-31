# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# Check for required arguments
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <FASTA_FILE> <OUTPUT_DIR>"
    exit 1
fi

FASTA=$1
OUTPUT_DIR=$2

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

STAR --runThreadN 4 --runMode genomeGenerate \
--genomeDir $OUTPUT_DIR \
--genomeFastaFiles $FASTA \
--genomeSAindexNbases 9
