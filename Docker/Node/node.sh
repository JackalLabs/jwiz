#!/bin/bash
set -e

# collecting keywords
# required keywords: NODE_NAME,  CHAIN_ID, 
for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo "$@"

# removing all older jackal inits (if they exist)
rm -rf $HOME/.canine

# making a new jackal directory
mkdir $HOME/.canine

# initializing the validator 
canined init $NODE_NAME --chain-id=$CHAIN_ID 

# copying the genesis
cp /home/common_store/genesis.json /root/.canine/config/genesis.json

# resetting the KV store
canined tendermint unsafe-reset-all --chain-id=$CHAIN_ID 

# adjusting the configs
export IPADDR=$(hostname -I | tr -d ' ')
sed -i "s|tcp://0\.0\.0\.0:26656|tcp://$IPADDR:26656|" $HOME/.canine/config/config.toml
sed -i "s|tcp://127\.0\.0\.1:26657|tcp://$IPADDR:26657|" $HOME/.canine/config/config.toml
sed -i "s|tcp://127\.0\.0\.1:26658|tcp://$IPADDR:26658|" $HOME/.canine/config/config.toml