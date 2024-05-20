#!/bin/bash


DOCKER_USERNAME="harirajn"
DOCKER_PASSWORD="dckr_pat_nCM37U34osFRQhy56q3aDueaJBw"


echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin


DOCKER_IMAGE_NAME="online_store"
DOCKER_DEV_REPO="dev"
DOCKER_PROD_REPO="prod"
DOCKERFILE_PATH=dockerfile
BRANCH=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)


build_and_push_image() {
    local tag=$1
    local repo=$2
    docker build -t $DOCKER_IMAGE_NAME:$tag -f $DOCKERFILE_PATH .
    docker tag $DOCKER_IMAGE_NAME:$tag $repo/$DOCKER_IMAGE_NAME:$tag
    docker push $repo/$DOCKER_IMAGE_NAME:$tag
}


if [ "$BRANCH" == "dev" ]; then
    build_and_push_image "dev" $DOCKER_DEV_REPO
elif [ "$BRANCH" == "master" ]; then
    # Check if the current branch is master and if it was merged from dev
    git merge-base --is-ancestor dev HEAD
    if [ $? -eq 0 ]; then
        build_and_push_image "prod" $DOCKER_PROD_REPO
    else
        echo "Skipping build. Not merged from dev."
    fi
else
    echo "Skipping build. Branch is not dev or master."
fi
