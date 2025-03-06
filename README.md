# FastQC Nextflow Workflow

## Overview
A Nextflow script based on the WDL implementation.

This script converts the original Workflow Description Language (WDL) implementation to Nextflow DSL2 syntax. The original WDL script can be found at:
https://github.com/MedicalEnvironment/wdl_workflow

## Features
- Nextflow provides better container integration and HPC scheduler compatibility than WDL
- The script leverages Singularity for reproducible execution of FastQC
- Input parameters can be modified in the script or via command-line options
- The parallel execution of FastQC jobs improves processing efficiency

## Usage
```bash
nextflow run fastqc_subworkflow.nf -profile standard
```

## Configuration
The workflow includes configuration for both local and HPC execution environments. You can modify input paths and parameters directly in the script or provide them via command-line options.
