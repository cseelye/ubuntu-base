ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION} as base

# Configure apt to never install recommended packages and do not prompt for user input
RUN printf 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";\n' >> /etc/apt/apt.conf.d/01norecommends
ARG DEBIAN_FRONTEND=noninteractive

# Set locale and timezone
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install --yes locales tzdata && \
    apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    locale-gen "en_US.UTF-8"
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install --yes \
        base-files \
        ca-certificates \
        curl \
        gnupg \
        python3 \
        python-is-python3 \
    && \
    apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="$PATH:/root/.local/bin"

# # Install and run apt-select
# RUN pip3 install \
#         --no-cache-dir \
#         --upgrade \
#         --compile \
#         --user \
#         apt-select \
#     && \
#     apt-select && \
#     cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
#     mv sources.list /etc/apt/

FROM base AS base-dev
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
COPY pip.conf /etc/pip.conf
RUN apt-get update && \
    apt-get install --yes \
        ack \
        base-files \
        curl \
        git \
        gnupg \
        jq \
        less \
        net-tools \
        make \
        openssh-client \
        python3-pip \
        unzip \
        vim \
    && apt-get autoremove --yes && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip

# Python dev tools
RUN pip install \
        autopep8 \
        bandit \
        black \
        debugpy \
        flake8 \
        mypy \
        pycodestyle \
        pydocstyle \
        pylint \
        pytest \
        virtualenvwrapper \
        yapf

# Install VS Code Live Share prerequisites
RUN curl -sSfLo /vsls-reqs https://aka.ms/vsls-linux-prereq-script && chmod +x /vsls-reqs && /vsls-reqs && rm /vsls-reqs

# Install docker client binary
ARG DOCKER_VERSION=20.10.9
RUN curl https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar -xz --strip-components=1 -C /usr/local/bin/ docker/docker

# Enable using git in the container
RUN git config --system --add safe.directory '*'
