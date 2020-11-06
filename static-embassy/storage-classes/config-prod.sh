#!/bin/bash

export STORAGE_NAMESPACE="shared"
export STORAGE_NFS_PREFIX="external-nfs-provisioner"
export STORAGE_NFS_PATH="/ifs/mykrobeatlas-prod-96594878"
export STORAGE_NFS_SERVER_1="10.35.112.204" # must be in the range of 10.35.112.202-220
export STORAGE_NFS_SERVER_2="10.35.112.207" # must be in the range of 10.35.112.202-220
export STORAGE_NFS_SERVER_3="10.35.112.210" # must be in the range of 10.35.112.202-220
export STORAGE_NFS_SERVER_4="10.35.112.213" # must be in the range of 10.35.112.202-220

sh ./deploy/deploy-rbac.sh
sh ./deploy/deploy-provisioner.sh 1
sh ./deploy/deploy-provisioner.sh 2
sh ./deploy/deploy-provisioner.sh 3
sh ./deploy/deploy-provisioner.sh 4
sh ./deploy/deploy-storage-class.sh 1
sh ./deploy/deploy-storage-class.sh 2
sh ./deploy/deploy-storage-class.sh 3
sh ./deploy/deploy-storage-class.sh 4
