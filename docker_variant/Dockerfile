# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Conda installation
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    zenity \
    build-essential \
    make \
    gcc \
    g++ \
    zlib1g-dev \
    gzip \
    tar \
    python3 \
    python3-pip \
    bzip2 \
    ca-certificates \
    libxml2-dev \
    libssl-dev \
    git \
    unzip && \
    rm -rf /var/lib/apt/lists/*
     
# Download and install Miniconda (lightweight version of Anaconda)
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add Conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Initialize Conda for bash shell (important for activating environments)
RUN conda init bash

# Install conda-forge and bioconda channels
RUN conda config --add channels tsnyder && \
    conda config --add channels r && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict
    
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create multiple conda environments for different versions of python:
RUN conda create -y -n enrichment_env \
    figlet \
    r-base \
    r-ggplot2 \
    r-ggridges \
    r-rcolorbrewer \
    r-biocmanager \
    bioconductor-clusterprofiler \
    bioconductor-biomart \
    bioconductor-annotationforge \
    bioconductor-enrichplot
  
ENV PATH=/opt/conda/envs/enrichment_env/bin:$PATH

# Make sure that the environment gets activated by default when running bash
#RUN echo "source activate enrichment_env" >> ~/.bashrc

# Set the default shell to bash to ensure the environment is activated
SHELL ["/bin/bash", "-c"]

# Set the working directory to /app (or your desired path)
WORKDIR /app/

# Optionally, copy files into the container (if you need to run commands on them)
#COPY . /app

#RUN useradd -m -s /bin/bash user && \
#    chown -R user:user /app

#USER user

# Set the default command to run bash, so the environment is activated
CMD ["bash"]
