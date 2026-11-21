FROM python:3.11-slim-bookworm AS python311
FROM ubuntu:24.04
COPY --from=python311 /usr/local /usr/local
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    autoconf automake bc bison build-essential bzip2 ca-certificates cmake cpio curl \
    device-tree-compiler file flex gawk gettext git gperf jq libbz2-1.0 libelf-dev \
    libffi8 libgmp-dev libisl-dev libjansson-dev liblzma5 libmpc-dev libmpfr-dev \
    libsqlite3-0 libssl-dev libtool libzstd-dev lz4 ninja-build openssl patch \
    pkg-config python3-yaml rsync squashfs-tools sudo texinfo unzip uuid-runtime \
    wget xxd xz-utils zlib1g-dev zstd \
 && python -c 'import bz2, ctypes, lzma, sqlite3, ssl, sys; assert sys.version_info[:2] == (3, 11)' \
 && /usr/bin/python3 -c 'import yaml' \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /build
