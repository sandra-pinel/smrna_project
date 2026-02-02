# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# Check for required arguments
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <FASTA_FILE> <OUT_DIR>"
    echo "  FASTA_FILE : Path to the filtered FASTA file (mandatory)"
    echo "  OUT_DIR    : Destination directory for the index (mandatory)"
    echo "Exiting..."
    exit 1
fi

FASTA_FILE=$1
OUT_DIR=$2

if [ ! -f "$FASTA_FILE" ]
then
    echo "ERROR: FASTA file $FASTA_FILE not found"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUT_DIR"

echo 
# Indexing command
echo "Indexing $(basename $FASTA_FILE)..."
STAR --runThreadN 4 --runMode genomeGenerate \
--genomeDir $OUT_DIR \
--genomeFastaFiles $FASTA_FILE \
--genomeSAindexNbases 9
echo "$(basename $FASTA_FILE) has been indexed and stored in $OUT_DIR."
