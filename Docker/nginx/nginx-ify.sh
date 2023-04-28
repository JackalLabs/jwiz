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

# creating the necessary volume directories if they don't exist already
mkdir -p html dhparam certs

# running the reverse-proxy
docker run -d -v '/root/html:/usr/share/nginx/html' \
-v '/root/dhparam:/etc/nginx/dhparam' \
-v '/root/vhost:/etc/nginx/vhost.d' \
-v '/root/certs:/etc/nginx/certs' \
-v '/var/run/docker.sock:/tmp/docker.sock:ro' \
--restart always \
-p 443:443 \
-p 80:80 \
--name $PROXYCONTAINER_NAME \
--network=$HOSTNETWORK \
jwilder/nginx-proxy:latest

# running the LE helper container
docker run -d -v '/root/html:/usr/share/nginx/html' \
-v '/root/dhparam:/etc/nginx/dhparam' \
-v '/root/vhost:/etc/nginx/vhost.d' \
-v '/root/certs:/etc/nginx/certs' \
-v '/var/run/docker.sock:/var/run/docker.sock:ro' \
--restart always \
-e DEFAULT_EMAIL=max@jackallabs.io \
-e NGINX_PROXY_CONTAINER=$PROXYCONTAINER_NAME \
--name $PROXYCONTAINER_NAME"_LE-helper" \
--network=$HOSTNETWORK \
jrcs/letsencrypt-nginx-proxy-companion:latest

# running the nginxified container
docker run --rm --name=$CONTAINER_NAME \
-e VIRTUAL_HOST=$HOSTNAME \
-e LETSENCRYPT_HOST=$HOSTNAME \
-e VIRTUAL_PORT=26657 \
--network=$HOSTNETWORK \
-v "/root/common_store:/home/common_store" \
-d $IMAGE_NAME