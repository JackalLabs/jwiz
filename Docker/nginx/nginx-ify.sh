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
docker run --rm --name $CONTAINER_NAME \
-e VIRTUAL_HOST=$HOSTNAME \
-e LETSENCRYPT_HOST=$HOSTNAME \
--network $NET_NAME \
-d $CONTAINER_NAME

# connecting the nginx container to the network 
docker network connect $HOSTNETWORK $PROXYCONTAINER_NAME