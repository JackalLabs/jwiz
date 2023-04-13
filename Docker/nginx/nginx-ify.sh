#!/bin/bash
set -e
# this scripts does:
# 1. Compiles the nginx containers
# 2. Compiles the target container
# 3. Creates a separate nginx network on docker
# 4. Sets up the letsencrypt companion container 
# 5. Enables https connection with the container (check with browser)

# building the dummy container
docker buildx build . -t nginx-dummy \
-f DummyNginxDockerfile
# groundwork for the nginx container
# creating the custom network
docker network remove nginx-net -f
docker network remove core-net -f 

docker network create core-net --driver overlay --attachable nginx-net

# creating the necessary volume directories if they don't exist already
mkdir -p html dhparam vhost certs

# powering on the nginx docker-compose file
docker-compose -f compose-ssl-nginx.yml up -d
docker run --rm --name nginx-dummy -e VIRTUAL_HOST=max.jackaldao.com -e LETSENCRYPT_HOST=max.jackaldao.com --network nginx-net -d nginx-dummy