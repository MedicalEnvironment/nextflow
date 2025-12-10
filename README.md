# FastQC Nextflow Workflow

## Overview
A fully automated Nextflow workflow for running FastQC analysis on genome FASTQ files using Docker.

This script converts the original Workflow Description Language (WDL) implementation to Nextflow DSL2 syntax. The original WDL script can be found at:
https://github.com/MedicalEnvironment/wdl_workflow

## Features
- **Fully Automated**: Just provide a tar.gz genome file and run the container
- **Docker-based**: No manual installation of dependencies required
- **Auto-discovery**: Automatically detects and processes all FASTQ files
- **Auto-extraction**: Automatically extracts tar.gz/tgz genome files
- **Parallel Processing**: Efficiently processes multiple FASTQ files in parallel
- **Reproducible**: Uses containerization for consistent results

## Quick Start with Docker

### Prerequisites
- Docker installed on your server
- Genome files in tar.gz format (or extracted .fastq.gz files)

### Build the Docker Image
```bash
cd /path/to/nextflow
docker build -t nextflow-fastqc .
```

### Run the Automated Workflow

**Option 1: With tar.gz genome file**
```bash
docker run -v /path/to/genome.tar.gz:/data/input/genome.tar.gz \
           -v /path/to/output:/data/output \
           nextflow-fastqc
```

**Option 2: With directory containing FASTQ files**
```bash
docker run -v /path/to/fastq/directory:/data/input \
           -v /path/to/output:/data/output \
           nextflow-fastqc
```

**Option 3: With Docker Compose (recommended)**
Create a `docker-compose.yml`:
```yaml
version: '3.8'
services:
  fastqc:
    image: nextflow-fastqc
    volumes:
      - ./input:/data/input      # Your genome files here
      - ./output:/data/output    # Results will appear here
    environment:
      - NXF_VER=24.10.0
```

Run with:
```bash
docker-compose up
```

### What Happens Automatically

1. **Container starts** and checks the `/data/input` directory
2. **Detects tar.gz files** and automatically extracts them
3. **Discovers all .fastq.gz files** in the input directory
4. **Runs FastQC** on each FASTQ file in parallel
5. **Saves results** to `/data/output` directory
6. **Reports completion** with a summary of generated files

### Directory Structure

Your server directory structure should look like:
```
your-project/
├── input/
│   └── genome.tar.gz          # Your genome file
├── output/                    # Results appear here automatically
└── docker-compose.yml         # Optional: for easy execution
```

After execution:
```
your-project/
├── input/
│   ├── genome.tar.gz
│   ├── sample1_R1.fastq.gz    # Extracted automatically
│   └── sample2_R1.fastq.gz
└── output/
    ├── sample1_R1_fastqc.html
    ├── sample1_R1_fastqc.zip
    ├── sample2_R1_fastqc.html
    └── sample2_R1_fastqc.zip
```

## Manual Usage (without Docker)

If you prefer to run Nextflow directly:

```bash
nextflow run fastqc_subworkflow.nf \
    --dataDir /path/to/fastq/files \
    --outputDir /path/to/output \
    -profile standard
```

## Configuration

### Custom Input Pattern
By default, the workflow looks for `*.fastq.gz` files. To customize:

```bash
docker run -v /path/to/input:/data/input \
           -v /path/to/output:/data/output \
           -e NXF_PARAMS="--inputPattern '*.fq.gz'" \
           nextflow-fastqc
```

### HPC Execution
The workflow includes an HPC profile for SLURM clusters:

```bash
nextflow run fastqc_subworkflow.nf \
    --dataDir /path/to/fastq \
    --outputDir /path/to/output \
    -profile hpc
```

## Troubleshooting

### No FASTQ files found
- Ensure your tar.gz file contains .fastq.gz or .fq.gz files
- Check that the input directory is correctly mounted to `/data/input`

### Permission issues
The container runs with your user ID to avoid permission problems. If you encounter issues:
```bash
docker run --user $(id -u):$(id -g) \
           -v /path/to/input:/data/input \
           -v /path/to/output:/data/output \
           nextflow-fastqc
```

### View logs
```bash
docker run -v /path/to/input:/data/input \
           -v /path/to/output:/data/output \
           nextflow-fastqc 2>&1 | tee workflow.log
```

## Advanced Usage

### Resume Failed Runs
Nextflow automatically supports resuming. Just rerun the same command:
```bash
docker run -v /path/to/input:/data/input \
           -v /path/to/output:/data/output \
           nextflow-fastqc
```

### Process Specific Files Only
Place only the files you want to process in the input directory.

## Support

For issues or questions, please refer to:
- Original WDL workflow: https://github.com/MedicalEnvironment/wdl_workflow
- Nextflow documentation: https://www.nextflow.io/docs/latest/

