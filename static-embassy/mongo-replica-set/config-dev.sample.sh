#!/bin/bash

export NAMESPACE="mykrobe-dev"
export MONGO_IMAGE="mongo:4.2"
export RELEASE_NAME="mykrobe"
export REPLICAS="3"
export APP_DB="atlas"
export MONGO_USER=`echo -n "admin" | base64`
export MONGO_PASSWORD=`echo -n <DEV_MONGO_ADMIN_PASSWORD> | base64` #secret
export APP_USER=`echo -n "atlas" | base64`
export APP_PASSWORD=`echo -n <DEV_MONGO_APP_PASSWORD> | base64` #secret
export MONGO_KEY=`echo -n <DEV_MONGO_KEY> | base64` #secret

export REQUEST_CPU="1000m"
export REQUEST_MEMORY="1Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="2000m"
export LIMIT_MEMORY="2Gi"
export LIMIT_STORAGE="4Gi"

export STORAGE_CLASS="external-nfs-provisioner-storage-class-3"
export STORAGE_DATA="10Gi"

sh ./deploy-mongo.sh