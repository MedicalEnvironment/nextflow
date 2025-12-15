# Dockerfile for automated Nextflow FastQC workflow
FROM nextflow/nextflow:24.10.0

# Install required dependencies (Amazon Linux uses yum/dnf)
USER root
RUN yum install -y \
       wget \
       tar \
       gzip \
       unzip \
       findutils \
       java-21-amazon-corretto \
       perl \
    && yum clean all

# Install FastQC
RUN wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip \
    && unzip fastqc_v0.12.1.zip \
    && mv FastQC /opt/FastQC \
    && chmod +x /opt/FastQC/fastqc \
    && ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc \
    && rm fastqc_v0.12.1.zip

# Create working directories
RUN mkdir -p /workflow /data/input /data/output /data/work /workflow/.nextflow

# Copy workflow files
WORKDIR /workflow
COPY fastqc_subworkflow.nf /workflow/
COPY nextflow.config /workflow/
COPY entrypoint.sh /workflow/

# Fix line endings and make entrypoint executable (handles Windows CRLF)
RUN sed -i 's/\r$//' /workflow/entrypoint.sh && chmod +x /workflow/entrypoint.sh

# Set proper permissions for all directories
RUN chmod -R 777 /workflow /data

# Set environment variables
ENV NXF_HOME=/workflow/.nextflow
ENV NXF_WORK=/data/work

# Expose volume mount points
VOLUME ["/data/input", "/data/output"]

# Set entrypoint
ENTRYPOINT ["/workflow/entrypoint.sh"]
