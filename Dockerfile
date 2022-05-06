# This file is part of REANA.
# Copyright (C) 2021, 2022 CERN.
#
# REANA is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

# Install base image and its dependencies
FROM python:3.8

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008, DL3013, DL3015
RUN apt-get update && \
    apt-get install -y \
    cmake \
    gcc \
    graphviz \
    graphviz-dev \
    libxrootd-client-dev \
    krb5-config \
    krb5-user \
    libauthen-krb5-perl \
    libkrb5-dev \
    vim-tiny \
    xrootd-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip

# Install dependencies
COPY requirements.txt /code/
RUN pip install --no-cache-dir -r /code/requirements.txt

# Copy cluster component source code
WORKDIR /code
COPY . /code

# Are we debugging?
ARG DEBUG=0
# hadolint ignore=DL3013
RUN if [ "${DEBUG}" -gt 0 ]; then pip install -e ".[debug,xrootd]"; else pip install ".[xrootd]"; fi;

# Are we building with locally-checked-out shared modules?
# hadolint ignore=SC2102
RUN if test -e modules/reana-commons; then pip install -e modules/reana-commons[kubernetes] --upgrade; fi

# Check if there are broken requirements
RUN pip check

# Set useful environment variables
ENV TERM=xterm \
    PYTHONPATH=/workdir
