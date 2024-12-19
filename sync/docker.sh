#!/usr/bin/env bash
set -e

# curl -sSL https://raw.githubusercontent.com/izhiqiang/sh/main/sync/docker.sh | bash

hubs=("hkccr.ccs.tencentyun.com/buildx/hub")

mysql_versions=("5.7" "8.0" "8.1" "8.2" "8.3" "8.4")
redis_versions=("6.2" "7.4")

function sync_mysql() {
    local hub=$1
    for version in "${mysql_versions[@]}"
    do
        local image="mysql:${version}"
        local target_image="${hub}:mysql-${version}"
        echo "Downloading ${image}"
        docker pull ${image}
        echo "rename ${image} -> ${target_image}"
        echo "push ${target_image}"
        docker push ${target_image}
    done
}

function sync_redis() {
    local hub=$1
    for version in "${redis_versions[@]}"
    do
        local image="redis:${version}"
        local target_image="${hub}:redis-${version}"
        echo "Downloading ${image}"
        docker pull ${image}
        echo "rename ${image} -> ${target_image}"
        echo "push ${target_image}"
        docker push ${target_image}
    done
}


for hub in "${hubs[@]}"
do
    sync_mysql ${hub}
    sync_redis ${hub}
done


