#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.dataDir = "~/input_data"
params.outputDir = "~/output_data"
params.imageFile = "~/containers/fastqc_v0.11.9_cv8.sif"
params.fastqFiles = ["miRNA_S8141Nr10.1.fastq.gz", "miRNA_S8141Nr130.1.fastq.gz", "miRNA_S8141Nr60.1.fastq.gz"]

process runFastQC {
    tag "$fastqFile"

    input:
    path fastqFile
    path imageFile
    path dataDir
    path outputDir

    output:
    path "${outputDir}/${fastqFile.baseName}_fastqc.zip"
    path "${outputDir}/${fastqFile.baseName}_fastqc.html"

    script:
    """
    singularity run -B ${dataDir}:/data -B ${outputDir}:/output ${imageFile} fastqc /data/${fastqFile} -o /output/
    """
}

workflow {
    fastq_ch = Channel.from(params.fastqFiles).map { file(it) }
    
    fastq_ch
        | runFastQC(imageFile: file(params.imageFile), dataDir: file(params.dataDir), outputDir: file(params.outputDir))
}
