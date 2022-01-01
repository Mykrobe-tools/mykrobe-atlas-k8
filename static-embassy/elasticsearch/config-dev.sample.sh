#!/bin/bash

export NAMESPACE="search"
export PREFIX="mykrobe-elasticsearch"
export REPLICAS=2
export IMAGE="docker.elastic.co/elasticsearch/elasticsearch:7.9.1"
export CLUSTER_NAME="mykrobe-dev"
# username must be "elastic" https://github.com/elastic/helm-charts/issues/273
export USERNAME=`echo -n "elastic" | base64`
export PASSWORD=`echo -n <PASSWORD> | base64`

# Resource limits
export REQUEST_CPU="500m"
export REQUEST_MEMORY="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="2Gi"

# Storage
export STORAGE_SIZE="30Gi"
export STORAGE_CLASS="default-cinder"

sh ./deploy.sh