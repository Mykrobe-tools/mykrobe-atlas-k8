#!/bin/bash

export NAMESPACE="search"
export PREFIX="mykrobe-elasticsearch"
export REPLICAS=2
export IMAGE="docker.elastic.co/elasticsearch/elasticsearch:7.9.1"
export CLUSTER_NAME="mykrobe"
export USERNAME=`echo -n <USERNAME> | base64`
export PASSWORD=`echo -n <PASSWORD> | base64`

# Resource limits
export REQUEST_CPU="500m"
export REQUEST_MEMORY="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="2Gi"

# Storage
export STORAGE_SIZE="30Gi"
export STORAGE_CLASS="external-nfs-provisioner-storage-class-2"

sh ./deploy.sh