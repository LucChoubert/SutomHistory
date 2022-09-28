#! /bin/bash

#Inspired from: https://github.com/fluxcd/helm-operator-get-started/blob/master/README.md

repository="lucchoubert/sutomhistory"
branch="master"
version=""
#Does not work on macos# commit=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1 | awk '{print tolower($0)}')
commit=$(openssl rand -hex 8)

last_version=$(docker image ls $repository | head -n 2 | tail -n 1 | sed 's/[^ ]*[ ]*\([^ ]*\).*/\1/')
last_version="0.0"
major_version=$(echo $last_version | cut -d '.' -f 1)
minor_version=$(echo $last_version | cut -d '.' -f 2)
minor_version=$((minor_version+1))
version="${major_version}.${minor_version}"

#image="${repository}:${branch}-${commit}"
image="${repository}:${version}"

echo ">>>> Building image ${image} <<<<"

docker build --build-arg RANDOMSTRING=${commit} --build-arg VERSION=${version} -t ${image} .

docker push ${image}

