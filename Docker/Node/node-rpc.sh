#!/bin/bash
set -e

# setting up the rpc connections
# collecting keywords
# required keywords: NODE_NAME, CHAIN_ID, NET_NAME, HOSTNAME, HOSTNETWORK, NODE_RELEASE
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# building the rpc-node docker image
docker buildx build . -t jackal-node \
-f NodeDockerfile \
--build-arg RELEASE=$NODE_RELEASE \
--build-arg NODE_SCRIPT=config-node.sh \
--build-arg CHAIN_ID=$CHAIN_ID

# Connecting the rpc-node to the nginx network
bash nginx-ify.sh NET_NAME=$NET_NAME \
HOSTNAME=$HOSTNAME \
HOSTNETWORK=$HOSTNETWORK \
PROXYCONTAINER_NAME=jackal-rpc-proxy \
CONTAINER_NAME=jackal-rpc \
IMAGE_NAME=jackal-node \
HTTPS_PORT=443 \
HTTP_PORT=80 \
PRIV=false

# configuring the rpc-node
docker exec jackal-rpc bash ./scripts/config-node.sh NODE_NAME=$NODE_NAME CHAIN_ID=$CHAIN_ID