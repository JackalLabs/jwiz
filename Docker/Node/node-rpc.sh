#!/bin/bash
set -e

# setting up the rpc connections
# collecting keywords
# required keywords: NODE_NAME, CHAIN_ID, HOSTNAME
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo "$@"

# building the rpc-node docker image
docker buildx build . -t rpc-node \
-f NodeDockerfile \
--build-arg RELEASE=$NODE_RELEASE \
--build-arg NODE_SCRIPT=node.sh \
--build-arg CHAIN_ID=$CHAIN_ID

# configuring the rpc-node
docker exec rpc-node config-node.sh NODE_NAME=$NODE_NAME CHAIN_ID=$CHAIN_ID

# Connecting the rpc-node to the nginx network
# (the rpc-node is run here)
nginx-ify.sh NET_NAME=node-rpc-net \
HOSTNAME=$HOSTNAME \
HOSTNETWORK=jackal-test \
PROXYCONTAINER_NAME=rpc-reverse-proxy \
CONTAINER_NAME=rpc-node 





