#!/bin/sh
set -eux

ENVE_VERSION=$1
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    wget --quiet -O /tmp/enve.tar.gz "https://github.com/joseluisq/enve/releases/download/v${ENVE_VERSION}/enve_v${ENVE_VERSION}_linux_amd64.tar.gz"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "armv8b" ] || [ "$ARCH" = "armv8l" ] || [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "aarch64_be" ]; then
    wget --quiet -O /tmp/enve.tar.gz "https://github.com/joseluisq/enve/releases/download/v${ENVE_VERSION}/enve_v${ENVE_VERSION}_linux_arm64.tar.gz"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
