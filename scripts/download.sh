# Check for required arguments
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <URL> <DIR> [UNZIP] [FILTER]"
    echo "  URL    : File URL (mandatory)"
    echo "  DIR    : Destination directory (mandatory)"
    echo "  UNZIP  : 'yes' to decompress (optional)"
    echo "  FILTER : pattern to exclude FASTA headers (optional)"
    echo "Exiting program..."
    exit 1
    
fi

URL=$1
DIR=$2
UNZIP=$3
FILTER=$4

mkdir -p "$DIR" 
filename=$(basename "$URL")
filepath="${DIR}/${filename}"

echo 

# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
echo "Downloading file from $URL to $DIR..."
wget -nc $URL -P $DIR #save in DIR and if it exists it skips the download (nc, no-clobber)


#----- MD5 check ------
md5_url="${URL}.md5"
# Intenta descargar el MD5 remoto solo si existe
if wget --spider -q "$md5_url"
then
    echo "Verifying MD5 for $filename..."
    local_md5=$(md5sum "$filepath" | cut -d' ' -f1)
    remote_md5=$(wget -q -O - "$md5_url" | awk '{print $1}')

    if [ "$local_md5" != "$remote_md5" ]
    then
        echo "MD5 Checksum failed for $filename, re-downloading..."
        wget -O "$filepath" "$URL"

        local_md5=$(md5sum "$filepath" | cut -d' ' -f1)
        if [ "$local_md5" != "$remote_md5" ]
        then
            echo "MD5 Checksum failed again. Exiting."
            exit 1
        else
            echo "MD5 Checksum passed after re-download."
        fi
    else
        echo "MD5 Checksum passed."
    fi
else
    echo "No MD5 file found for $filename, skipping checksum."
fi

echo 

# Safety check
if [ -n "$FILTER" ] && [ "$UNZIP" != "yes" ]
then
    echo "ERROR: FILTER requires UNZIP=yes (FASTA must be decompressed first)"
    exit 1
fi

# uncompress the dowloaded file with gunzip if the third argument $3 is 'yes'
unzipped_filepath="${filepath%.gz}" # ${variable%patrón} --> Removes the end of a string that matches the pattern    

if [ "$UNZIP" == "yes" ]
then
    if [ ! -f "$unzipped_filepath" ] # If this file DOES NOT EXIST ...
    then
        echo "Descompressing $filename..."
        gunzip -k $filepath
        echo "File $filename decompressed as $(basename $unzipped_filepath) in $DIR."
    else
        echo "File $unzipped_filepath already exists, skipping decompression."
    fi   
fi

echo

# filter the sequences based on a word contained in their header lines
# sequences containing the specified word in their header should be **excluded**

if [ "$UNZIP" == "yes" ] && [ -n "$FILTER" ] # for filtering fasta decompression is needed
then
    filtered_filepath="${unzipped_filepath%.fasta}_filtered.fasta"
    
    # Only filter if the filtered file doesn't exist yet
    if [ ! -f "$filtered_filepath" ]
    then
        echo "Removing sequences from $(basename "$unzipped_filepath") with pattern: '$FILTER'..."
        # # filter the sequences based on a word contained in their header lines

        seqkit grep -v -r -n -p "$FILTER" "$unzipped_filepath" > "$filtered_filepath"
        echo "El archivo $(basename $unzipped_filepath) ha sido filtrado y guardado como $(basename $filtered_filepath)."
        
    else
        echo "Filtered file $(basename "$filtered_filepath") already exists, skipping filtering."
    fi

    # Remove not filtered fasta (for space)
    echo "Removing unfiltered FASTA file: $(basename "$unzipped_filepath")..."
    rm -f $unzipped_filepath 
    echo "File $unzipped_filepath has been removed."
fi
