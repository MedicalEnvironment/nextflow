#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.dataDir = "/home_beegfs/akbar01/material/03_example_data/R1"
params.outputDir = "/home_beegfs/akbar01/nextflow_hpc/output"
params.imageFile = "/home_beegfs/akbar01/nextflow_hpc/containers/fastqc_v0.11.9_cv8.sif"
params.fastqFiles = ["sod1_R1_001.fastq.gz", "sod3_R1_001.fastq.gz", "sod5_R1_001.fastq.gz"]

// Create channels
fastq_ch = Channel.fromList(params.fastqFiles)
    .map { filename -> 
        file("${params.dataDir}/${filename}")
    }

process runFastQC {
    tag "${fastqFile.simpleName}"
    publishDir params.outputDir, mode: 'copy'
    
    input:
    path fastqFile
    
    output:
    path "${fastqFile.simpleName}_fastqc.zip"
    path "${fastqFile.simpleName}_fastqc.html"
    
    script:
    """
    # Create a local output directory
    mkdir -p output
    
    # Run FastQC using singularity
    singularity exec \\
        ${params.imageFile} \\
        fastqc -o output ${params.dataDir}/${fastqFile.getName()}
    
    # Move the output files to the expected location
    mv output/${fastqFile.simpleName}_fastqc.zip .
    mv output/${fastqFile.simpleName}_fastqc.html .
    """
}

workflow {
    runFastQC(fastq_ch)
}
