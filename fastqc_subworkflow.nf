#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// Default parameters for automated Docker execution
params.dataDir = "/data/input"
params.outputDir = "/data/output"
params.inputPattern = "*.fastq.gz"  // Pattern to match FASTQ files

// Auto-discover FASTQ files from input directory
fastq_ch = Channel
    .fromPath("${params.dataDir}/${params.inputPattern}")
    .ifEmpty { error "No FASTQ files found in ${params.dataDir} matching pattern ${params.inputPattern}" }

process runFastQC {
    tag "${fastqFile.simpleName}"
    publishDir params.outputDir, mode: 'copy'
    container 'biocontainers/fastqc:v0.11.9_cv8'
    
    input:
    path fastqFile
    
    output:
    path "${fastqFile.simpleName}_fastqc.zip"
    path "${fastqFile.simpleName}_fastqc.html"
    
    script:
    """
    fastqc -o . ${fastqFile}
    """
}

workflow {
    runFastQC(fastq_ch)
}
