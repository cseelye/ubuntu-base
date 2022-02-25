ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION}

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
