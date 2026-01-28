

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
echo "Descargando archivo de $URL, guardándolo en $DIR"
wget $URL -P $DIR
filename=$(basename $URL)

if [ "$UNZIP" == "yes" ]
then
    filename=$(basename $URL)
    gunzip -k $DIR/$filename


# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
