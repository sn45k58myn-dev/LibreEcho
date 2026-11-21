FROM python:3.11-slim-bookworm@sha256:a83ba18aef0f865b1a4a611c2cf460fe446f2795673bbb9fe43be570439e3b39 AS python311
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289
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
COPY bootstrap.sh cmake-for-image cmake-with-ort-mirror image.sh package.sh prepare-ort.py prepare-wake-deps.py sources.sh stage-key.py stage-sources.py verify.py workflow-step.py /recipe/
