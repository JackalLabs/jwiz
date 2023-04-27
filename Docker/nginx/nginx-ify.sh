#!/bin/bash
set -e
# required keywords: HOSTNAME, NET_NAME, HOSTNETWORK, PROXYCONTAINER_NAME 
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# groundwork for the nginx container
# creating the custom network
docker network remove $NET_NAME -f

docker network create --attachable $NET_NAME

# creating the necessary volume directories if they don't exist already
mkdir -p html dhparam certs

# powering on the nginx docker-compose file
docker-compose -f compose-ssl-nginx.yml up -d
set +e
# connecting the spawned containers to their networks
docker network connect $HOSTNETWORK reverse-proxy 
# docker network connect $NET_NAME reverse-proxy

docker network connect $HOSTNETWORK letsencrypt-helper 
# docker network connect $NET_NAME letsencrypt-helper 
set -e

# changing proxy container names from the default
docker rename reverse-proxy $PROXYCONTAINER_NAME
docker rename letsencrypt-helper $PROXYCONTAINER_NAME"_LE-helper"

# running the nginxified container
docker run --rm --name=$CONTAINER_NAME \
-e VIRTUAL_HOST=$HOSTNAME \
-e LETSENCRYPT_HOST=$HOSTNAME \
-e VIRTUAL_PORT=26657 \
--network=$HOSTNETWORK \
-v "/root/common_store:/home/common_store" \
-d $IMAGE_NAME

# docker network connect $NET_NAME $CONTAINER_NAME