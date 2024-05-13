#!/bin/bash

DOCKERFILE_PATH="dockerfile"

IMAGE_TAG="online_store"

docker build -t $IMAGE_TAG -f $DOCKERFILE_PATH .

if [ $? -eq 0 ]; then
    echo "Docker image build successful: $IMAGE_TAG"
else
    echo "Error: Docker image build failed"
    exit 1
fi
