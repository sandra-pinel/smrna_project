# cleanup.sh - Remove generated files from the pipeline
# Usage: ./cleanup.sh [data|resources|output|logs]
# If no arguments are given, everything is cleaned.

set -euo pipefail

# If no arguments are provided, clean everything
if [ "$#" -eq 0 ]; then
    echo "No arguments provided. Cleaning all generated files..."

    rm -f data/*.fastq.gz 2>/dev/null || true

    rm -f res/contaminants.fasta.gz res/contaminants_filtered.fasta 2>/dev/null || true
    rm -rf res/contaminants_idx/* 2>/dev/null || true

    rm -rf out/* 2>/dev/null || true
    rm -rf log/* 2>/dev/null || true

    echo "✔ All generated files removed."
    exit 0
fi

# Clean selected components
for target in "$@"; do
    case "$target" in 
        data)
            echo "Cleaning FASTQ files from data/..."
            rm -f data/*.fastq.gz 2>/dev/null || true
            ;;
        resources)
            echo "Cleaning resources..."
            rm -f res/contaminants.fasta.gz res/contaminants_filtered.fasta 2>/dev/null || true
            rm -rf res/contaminants_idx/* 2>/dev/null || true
            ;;
        output)
            echo "Cleaning output files..."
            rm -rf out/* 2>/dev/null || true
            ;;
        logs)
            echo "Cleaning log files..."
            rm -rf log/* 2>/dev/null || true
            ;;
        *)
            echo "❌ Unknown option: $target"
            echo "Valid options: data resources output logs"
            exit 1
            ;;
    esac
done
