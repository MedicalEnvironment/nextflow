#!/bin/bash
set -e

echo "========================================="
echo "Automated Nextflow FastQC Workflow"
echo "========================================="

# Default directories
INPUT_DIR="/data/input"
OUTPUT_DIR="/data/output"
WORK_DIR="/data/work"

# Check if input directory exists and has files
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory $INPUT_DIR does not exist!"
    echo "Please mount your data directory to /data/input"
    exit 1
fi

# Check for tar.gz files in input directory
TAR_FILES=$(find "$INPUT_DIR" -maxdepth 1 -name "*.tar.gz" -o -name "*.tgz" 2>/dev/null)

if [ -n "$TAR_FILES" ]; then
    echo "Found compressed genome files. Extracting..."
    for tar_file in $TAR_FILES; do
        echo "  Extracting: $(basename $tar_file)"
        tar -xzf "$tar_file" -C "$INPUT_DIR"
    done
    echo "Extraction complete!"
fi

# Count FASTQ files
FASTQ_COUNT=$(find "$INPUT_DIR" -name "*.fastq.gz" -o -name "*.fq.gz" | wc -l)

if [ "$FASTQ_COUNT" -eq 0 ]; then
    echo "Error: No FASTQ files found in $INPUT_DIR"
    echo "Please ensure your genome files are extracted or in .fastq.gz format"
    exit 1
fi

echo "Found $FASTQ_COUNT FASTQ file(s) to process"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$WORK_DIR"

# Set proper permissions
chmod -R 755 "$OUTPUT_DIR" "$WORK_DIR" 2>/dev/null || true

echo ""
echo "Configuration:"
echo "  Input directory:  $INPUT_DIR"
echo "  Output directory: $OUTPUT_DIR"
echo "  Work directory:   $WORK_DIR"
echo ""
echo "Starting Nextflow workflow..."
echo "========================================="

# Run Nextflow workflow
cd /workflow
nextflow run fastqc_subworkflow.nf \
    -profile standard \
    --dataDir "$INPUT_DIR" \
    --outputDir "$OUTPUT_DIR" \
    -with-docker \
    -resume

# Check if workflow completed successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "Workflow completed successfully!"
    echo "Results are available in: $OUTPUT_DIR"
    echo "========================================="
    
    # List output files
    echo ""
    echo "Generated files:"
    ls -lh "$OUTPUT_DIR"
else
    echo ""
    echo "========================================="
    echo "Workflow failed! Check the logs above."
    echo "========================================="
    exit 1
fi
