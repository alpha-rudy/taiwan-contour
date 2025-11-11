FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale to UTF-8
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install system dependencies and tools
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    make \
    git \
    curl \
    wget \
    # Archive tools
    p7zip-full \
    unzip \
    # GDAL and geospatial tools
    gdal-bin \
    python3-gdal \
    libgdal-dev \
    # OSM tools
    osmium-tool \
    osmctools \
    # Python 3 and pip
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    # Text processing
    sed \
    # Additional utilities
    sudo \
    vim \
    nano \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir --break-system-packages \
    pyosmium \
    ogr2osm \
    pyhgtmap \
    numpy

# Create builder user with sudo permissions
RUN useradd -m -s /bin/bash builder && \
    echo "builder:builder" | chpasswd && \
    usermod -aG sudo builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Change ownership of workspace to builder
RUN chown -R builder:builder /workspace

# Switch to builder user
USER builder

# Set default shell
SHELL ["/bin/bash", "-c"]

# Set default command
CMD ["/bin/bash"]
