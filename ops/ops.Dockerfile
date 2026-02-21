FROM ubuntu:24.04

## BASIC SETUP
# Explicitly prevent adding other architectures
# Install basic dependencies
RUN rm -f /etc/dpkg/dpkg.cfg.d/multiarch && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    locales \
    watchman \
    wget \
    unzip \
    sudo \
    zip \
    curl \
    git-all \
    xz-utils \
    libglu1-mesa \
    libc6 \
    libstdc++6 \
    libbz2-1.0 \
    libgtk-4-1 \
    libadwaita-1-0 \
    lsb-release \
    gnupg \
    ca-certificates \
    build-essential && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Configure git user name and email
RUN git config --global user.name "Deddy Kakunsi" && \
    git config --global user.email "deddy.kakunsi@gmail.com"

ENV INSTALLATION_DIR="/opt"
WORKDIR ${INSTALLATION_DIR}

## DOCKER SETUP
# Install Docker inside docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## AI Agents SETUP
# Install Copilot CLI
RUN curl -fsSL https://gh.io/copilot-install | bash

# Clean everything
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Default shell to bash
SHELL ["/bin/bash", "-c"]

