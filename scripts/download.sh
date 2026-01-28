

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <URL> <DIR> [UNZIP] [FILTER] "
    echo "  URL       : URL del archivo a descargar (obligatorio)"
    echo "  DIR       : Carpeta destino (obligatorio)"
    echo "  UNZIP     : 'yes' si quieres descomprimir el archivo descargado (opcional)"
    echo "  FILTER    : palabra para excluir secuencias de headers FASTA (opcional)"
    exit 1
fi

URL=$1
DIR=$2
UNZIP=$3
FILTER=$4

echo 

# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
echo "Descargando archivo de $URL, guardándolo en la carpeta $DIR..."
mkdir -p $DIR
wget $URL -P $DIR

echo 

# uncompress the dowloaded file with gunzip if the third argument $3 is 'yes'
if [ "$UNZIP" == "yes" ]
then
    filename=$(basename $URL)
    echo "Descomprimiendo $filename..."
    gunzip -k ${DIR}/${filename}
    unzip_filename=$(basename $URL .gz)
fi

# filter the sequences based on a word contained in their header lines:
#sequences containing the specified word in their header should be **excluded**

if [ -n "$FILTER" ]
then
    echo "Filtrando secuencias de $FILTER"
    filter_filename=$(basename $URL .fasta.gz)
    seqkit grep -v -r -p "$FILTER" "${DIR}/${unzip_filename}" > "${DIR}/${filter_filename}_filtered.fasta"
fi

