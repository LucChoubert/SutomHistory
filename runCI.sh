#! /bin/bash

set -x

# This is to propagate RC
set -o pipefail

#Inspired from: https://github.com/fluxcd/helm-operator-get-started/blob/master/README.md

repository="docker.io/lucchoubert/sutomhistory"
branch="master"
version=""
#Does not work on macos# commit=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 | awk '{print tolower($0)}')
commit=$(openssl rand -hex 8)

#last_version=$(podman image ls $repository | head -n 2 | tail -n 1 | sed 's/[^ ]*[ ]*\([^ ]*\).*/\1/')
last_version=$(podman search --no-trunc --list-tags $repository | tail -n 1 | sed 's/[^ ]*[ ]*\([^ ]*\).*/\1/')
retVal=$?
if [ $retVal -ne 0 ]; then
    last_version="0.0"
    echo "Error"
fi

major_version=$(echo $last_version | cut -d '.' -f 1)
minor_version=$(echo $last_version | cut -d '.' -f 2)
minor_version=$((minor_version+1))
version="${major_version}.${minor_version}"

#image="${repository}:${branch}-${commit}"
image="${repository}:${version}"

echo ">>>> Building image ${image} <<<<"

# This is for debug
#exit 0

# Following line is to build multi arch on with docker. Works well on Windows.
#/home/luc/.docker/cli-plugins/docker-buildx build --platform linux/amd64,linux/arm64 -t ${image} --push .

# Build the container for multi architecture with podman
#podman build --build-arg RANDOMSTRING=${commit} --build-arg VERSION=${version} -t ${image} .
#podman build --platform linux/arm64 --platform linux/amd64 --manifest docker.io/lucchoubert/sutomhistory:0.2 .
podman build --platform linux/arm64 --platform linux/amd64 --manifest ${image} .

# Pushing to the master Repo
#podman push ${image}
#podman manifest push docker.io/lucchoubert/sutomhistory:0.2 docker://docker.io/lucchoubert/sutomhistory:0.2
podman manifest push ${image} docker://${image}

