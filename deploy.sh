#!/bin/bash

# Docker Hub credentials
DOCKER_USERNAME="harirajn"
DOCKER_PASSWORD="dckr_pat_nCM37U34osFRQhy56q3aDueaJBw"

# Authenticate with Docker Hub
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Define variables
DOCKER_IMAGE_NAME="online_store"
DOCKER_DEV_REPO="dev"
DOCKER_PROD_REPO="prod"
DOCKERFILE_PATH=dockerfile
BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

# Build and push the Docker image
build_and_push_image() {
    local tag=$1
    local repo=$2
    docker build -t $DOCKER_IMAGE_NAME:$tag -f $DOCKERFILE_PATH .
    docker tag $DOCKER_IMAGE_NAME:$tag $repo/$DOCKER_IMAGE_NAME:$tag
    docker push $repo/$DOCKER_IMAGE_NAME:$tag
}

# Main logic
if [ "$BRANCH" == "dev" ]; then
    build_and_push_image "dev" $DOCKER_DEV_REPO
elif [ "$BRANCH" == "master" ]; then
    build_and_push_image "prod" $DOCKER_PROD_REPO
else
    echo "Skipping build. Branch is not dev or master."
fi
