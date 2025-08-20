#!/bin/bash

ARCH=$(uname -m)

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Push arm64-box..."
    docker push tsxcloud/enshrouded-arm:arm64
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Building for amd64..."
    docker push tsxcloud/enshrouded-arm:amd64
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

docker manifest create --amend tsxcloud/enshrouded-arm:latest \
  tsxcloud/enshrouded-arm:amd64 \
  tsxcloud/enshrouded-arm:arm64

docker manifest push --purge tsxcloud/enshrouded-arm:latest
