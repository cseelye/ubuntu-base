ARG UBUNTU_VERSION=20.04

#
# base target - the base image
#
FROM ubuntu:${UBUNTU_VERSION} as base
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
ARG UBUNTU_VERSION

# Configure apt to never install recommended packages and do not prompt for user input
RUN printf 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";\n' >> /etc/apt/apt.conf.d/01norecommends
ARG DEBIAN_FRONTEND=noninteractive

# Hardcoded mirrors close to me previously selected using apt-select
COPY sources.list* /tmp/
RUN if [[ $(uname -m) == "x86_64" && ${UBUNTU_VERSION} == "22.04" ]]; then \
        mv /tmp/sources.list /etc/apt/sources.list; \
    fi; \
    rm -f /tmp/sources.list*

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


#
# base-dev target - a common base image for development containers
#
FROM base AS base-dev
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
ARG UBUNTU_VERSION

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
COPY pip.conf /etc/pip.conf
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
        yapf
COPY pylintrc /etc/pylintrc

ENV TERM=xterm-256color
COPY bashrc /root/.bashrc

# Enable using git in the container
RUN git config --system --add safe.directory '*'

# Install docker client binary
COPY install-docker.sh /tmp/install-docker.sh
RUN /tmp/install-docker.sh

# Install VS Code server, live share prerequisites, extensions
COPY vscode.sh /tmp/vscode.sh
RUN /tmp/vscode.sh

ENTRYPOINT []
CMD ["/bin/bash"]


#
# base-ansible-dev target - extended dev container for ansible work
#
FROM base-dev AS base-ansible-dev
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Install latest ansible and ansible-lint
RUN pip install ansible ansible-lint jmespath

# # Create virtualenvs for other versions of ansible
# RUN pip install virtualenvwrapper
# ENV VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 VIRTUALENVWRAPPER_VIRTUALENV=/root/.local/bin/virtualenv

# # Ansible 2.12
# RUN source /root/.local/bin/virtualenvwrapper.sh && \
#     mkvirtualenv ansible-2.12 && \
#     pip install --no-user ansible==5.10.0 jmespath
