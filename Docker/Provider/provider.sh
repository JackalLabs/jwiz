#!/bin/bash
set -e

# collecting keywords
# required keywords: PROVIDER_RELEASE, CHAIN_ID, HOSTNAME, HOSTNETWORK
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# building the storage provider docker image
docker buildx build . -t provider \
-f ProviderDockerfile \
--build-arg RELEASE=$PROVIDER_RELEASE

# nginx-ifying the provider
bash nginx-ify.sh NET_NAME=provider-net \
HOSTNAME=$HOSTNAME \
HOSTNETWORK=$HOSTNETWORK \
PROXYCONTAINER_NAME=provider-proxy \
CONTAINER_NAME=jackal-provider \
IMAGE_NAME=provider \
HTTPS_PORT=442 \
HTTP_PORT=81 \
PRIV=true

# connecting the storage provider to the network:
# connecting the tendermint endpoint
docker exec jackal-provider jprovd client config node "https://max.jackaldao.com:443"
# creating my own provider endpoint
docker exec jackal-provider jprovd init "https://max2.jackaldao.com" $TOTALSPACE "" 