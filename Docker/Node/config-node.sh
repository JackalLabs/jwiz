#!/bin/bash
set -e

# running inside the blockchain
# collecting keywords
# required keywords: NODE_NAME, CHAIN_ID, 
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

# initializing the regular node
canined init $NODE_NAME --chain-id=$CHAIN_ID 

# copying the genesis + gentxs
cp /home/common_store/genesis.json /root/.canine/config/genesis.json
cp -RT /home/common_store/gentx /root/.canine/config/gentx

# resetting the genesis state
canined collect-gentxs --chain-id=${CHAIN_ID}

# resetting the KV store
canined tendermint unsafe-reset-all --chain-id=$CHAIN_ID 

# adjusting the configs
export IPADDR=$(hostname -I | tr -d ' ' )
sed -i "s|tcp://0\.0\.0\.0:26656|tcp://$IPADDR:26656|" $HOME/.canine/config/config.toml
sed -i "s|tcp://127\.0\.0\.1:26657|tcp://$IPADDR:26657|" $HOME/.canine/config/config.toml
sed -i "s|tcp://127\.0\.0\.1:26658|tcp://$IPADDR:26658|" $HOME/.canine/config/config.toml