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
    osmium \
    ogr2osm \
    pyhgtmap[geotiff] \
    numpy

# Create builder user with sudo permissions
# Use ARG to allow customization of UID/GID at build time
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN set -e && \
    # Create or modify group
    if getent group ${GROUP_ID} >/dev/null; then \
        GROUP_NAME=$(getent group ${GROUP_ID} | cut -d: -f1); \
    else \
        groupadd -g ${GROUP_ID} builder; \
        GROUP_NAME=builder; \
    fi && \
    # Create user with the group
    if id -u ${USER_ID} >/dev/null 2>&1; then \
        USER_NAME=$(id -un ${USER_ID}); \
        usermod -l builder -d /home/builder -m ${USER_NAME} 2>/dev/null || true; \
    else \
        useradd -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} builder; \
    fi && \
    # Set password and sudo permissions
    echo "builder:builder" | chpasswd && \
    usermod -aG sudo builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Switch to builder user
USER builder

# Set default shell
SHELL ["/bin/bash", "-c"]

# Set default command
CMD ["/bin/bash"]
