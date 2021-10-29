#!/bin/bash
#
# Primary-Secondary-Arbiter Replica Set

export SSH_PUB_KEY=$(cat ~/.ssh/id_ed25519.pub) # path to yours public key
export RS_NAME="rs01"
export MONGODB_VERSION="5.0.2"

name=mongodb-rs-psa  # prefix in VMs (for use name of current dir: `name=${PWD##*/}`)
arbiter=${name}-arb  # arbiter name
node1=${name}-1      # worker node 1 name
node2=${name}-2      # worker node 2 name

init_rs="rs.initiate({_id: '${RS_NAME}', members: [
  {_id: 0, host: '${node1}.multipass:27017'},
  {_id: 1, host: '${node2}.multipass:27017'}
  ]})"

if [ "$1" == "create" ]; then
  echo "Create VMs with prefix: ${name}"
  envsubst < cloud-init.yml > cloud-init.yml.rendered

  multipass launch --name $arbiter --cpus 1 --mem 1G --disk 3G --cloud-init ./cloud-init.yml.rendered
  multipass launch --name $node1   --cpus 1 --mem 1G --disk 5G --cloud-init ./cloud-init.yml.rendered
  multipass launch --name $node2   --cpus 1 --mem 1G --disk 5G --cloud-init ./cloud-init.yml.rendered

  multipass exec $node1 -- mongosh --eval "${init_rs}"
  sleep 10
  multipass exec $node2 -- mongosh --eval "rs.stepDown()"
  sleep 3
  multipass exec $node1 -- mongosh --eval 'db.adminCommand({"setDefaultRWConcern": 1, "defaultWriteConcern": {"w": 2}})'
  multipass exec $node1 -- mongosh --eval "rs.addArb('${arbiter}.multipass:27017')"
  multipass exec $arbiter -- mongosh --eval "rs.status()"

  rm cloud-init.yml.rendered
  exit
fi

if [ "$1" == "destroy" ]; then
  echo "Destroy VMs with prefix: ${name}"
  multipass delete $arbiter
  multipass delete $node1
  multipass delete $node2
  multipass purge
  exit
fi

echo "Need argument: create or destroy"
