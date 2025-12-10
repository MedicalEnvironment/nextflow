# Dockerfile for automated Nextflow FastQC workflow
FROM nextflow/nextflow:24.10.0

# Install required dependencies (Debian/Ubuntu style)
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       curl \
       wget \
       tar \
       gzip \
       unzip \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install FastQC
RUN wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip \
    && unzip fastqc_v0.12.1.zip \
    && mv FastQC /opt/FastQC \
    && chmod +x /opt/FastQC/fastqc \
    && ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc \
    && rm fastqc_v0.12.1.zip

# Create working directories
RUN mkdir -p /workflow /data/input /data/output /data/work

# Copy workflow files
WORKDIR /workflow
COPY fastqc_subworkflow.nf /workflow/
COPY nextflow.config /workflow/
COPY entrypoint.sh /workflow/

# Make entrypoint executable
RUN chmod +x /workflow/entrypoint.sh

# Set environment variables
ENV NXF_HOME=/workflow/.nextflow
ENV NXF_WORK=/data/work

# Expose volume mount points
VOLUME ["/data/input", "/data/output"]

# Set entrypoint
ENTRYPOINT ["/workflow/entrypoint.sh"]
