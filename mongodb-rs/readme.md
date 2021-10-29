# MongoDB ReplicaSet with multipass

## Create configured mongodb replicaset

Create mongodb replicaset with three data nodes. You can add more nodes in script.

- install multipass
- edit `multipass_vm.sh`

```
export SSH_PUB_KEY=$(cat ~/.ssh/id_ed25519.pub) # path to yours public key
export RS_NAME="rs00"                           # replicaset name
export MONGODB_VERSION="5.0.2"                  # mongodb version >= 5.0.0

name="mongo-rs-psa"                             # prefix in VMs names
```

- run `multipass_vm.sh create`
