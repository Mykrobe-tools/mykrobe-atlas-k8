#!/bin/bash

export NAMESPACE="search-uat"
export PREFIX="mykrobe-elasticsearch"
export REPLICAS=2
export IMAGE="docker.elastic.co/elasticsearch/elasticsearch:7.9.1"
export CLUSTER_NAME="mykrobe-uat"
export USERNAME=`echo -n "elastic" | base64`
export PASSWORD=`echo -n <UAT_ES_PASSWORD> | base64` #secret

# Resource limits
export REQUEST_CPU="500m"
export REQUEST_MEMORY="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="2Gi"
export STORAGE_SIZE="30Gi"

sh ./deploy.sh