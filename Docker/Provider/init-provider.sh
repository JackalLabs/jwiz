#!/bin/bash
set -e

# collecting keywords
# required keywords: PROVIDER_RELEASE, NODE_RELEASE, CHAIN_ID
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# initializing the jackal validator testnet
bash init-subnet.sh NUM_VALIDATORS=1 RELEASE=$NODE_RELEASE CHAIN_ID=$CHAIN_ID

# building the rpc-node docker image
docker buildx build . -t rpc-node \
-f NodeDockerfile \
--build-arg RELEASE=$NODE_RELEASE \
--build-arg NODE_SCRIPT=node.sh \
--build-arg CHAIN_ID=$CHAIN_ID

# building the storage provider docker image
docker buildx build . -t provider \
-f ProviderDockerfile \
--build-arg RELEASE=$PROVIDER_RELEASE

# nginx-ification of docker containers
# connecting the docker containers

# bringing the node online 
docker run -d -v "/root/common_store:/home/common_store" \
--name=rpc-node rpc-node

# bringing the provider online
docker run -d -v "/root/provider_store:/home/provider_store" \
--name=jprov provider 

# initializing the node
docker exec rpc-node bash /home/canine-node/scripts/node.sh NODE_NAME=jnode CHAIN_ID=testing

# collecting the IP address of the rpc-node
NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rpc-node | tr -d '+')

# connecting the storage provider to the network
# connecting the tendermint endpoint
docker exec jprov jprovd client config node "https://rpc-testjackal.nodeist.net:443"
# docker exec jprov jprovd init "http://$NODE_IP" $TOTALSPACE ""

# creating my own provider endpoint
docker exec jprov jprovd init "https://storagep1.chainstrategies.cloud" $TOTALSPACE "" 