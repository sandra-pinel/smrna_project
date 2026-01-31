if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <URL> <DIR> [UNZIP] [FILTER] "
    echo "  URL       : URL del archivo a descargar (obligatorio)"
    echo "  DIR       : Carpeta destino (obligatorio)"
    echo "  UNZIP     : 'yes' si quieres descomprimir el archivo descargado (opcional)"
    echo "  FILTER    : palabra para excluir secuencias de headers FASTA (opcional)"
    exit 1
    echo " Saliendo del programa..."
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
echo "Descargando archivo de $URL, guardándolo en la carpeta $DIR..."
mkdir -p $DIR
wget -nc $URL -P $DIR #save in DIR and if it exists it skips the download (nc, no-clobber)

echo 

# uncompress the dowloaded file with gunzip if the third argument $3 is 'yes'
if [ "$UNZIP" == "yes" ]
then
    unzipped_filepath="${filepath%.gz}" # ${variable%patrón} --> Removes the end of a string that matches the pattern    

    if [ ! -f $unzipped_filepath ] # If this file DOES NOT EXIST ...
    then
        echo "Descomprimiendo $filename..."
        gunzip -k $filepath
        echo "El archivo $filename ha sido filtrado y guardado como $(basename $unzipped_filepath) en $DIR"
    else
        echo "El archivo $unzipped_filepath" ya existe, saltando descomprensión
    fi   
fi

echo
# filter the sequences based on a word contained in their header lines
# sequences containing the specified word in their header should be **excluded**

if [ -n "$FILTER" ]; then

    filtered_filepath="${unzipped_filepath%.fasta}_filtered.fasta"
    
    # Only filter if the filtered file doesn't exist yet
    if [ ! -f "$filtered_filepath" ]; then
        echo "Filtrando secuencias con el siguiente patrón: '$FILTER'..."
        # Using seqkit grep to exclude (-v) the patterns (-p)
        seqkit grep -v -r -n -p "$FILTER" "$unzipped_filepath" > "$filtered_filepath"
        echo "El archivo $(basename $unzipped_filepath) ha sido filtrado y guardado como $(basename $filtered_filepath) en $DIR"
    else
        echo "El archivo $(basename $filtered_filepath) ya existe, saltando filtrado."
    fi
fi

