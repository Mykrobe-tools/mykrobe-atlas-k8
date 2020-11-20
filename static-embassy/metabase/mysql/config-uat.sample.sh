#!/bin/bash

export NAMESPACE="mykrobe-insight-uat"
export PREFIX="mykrobe"
export MYSQL_IMAGE="mysql:5.7.28"
export DATABASE="mykrobe"
export DB_USER="mykrobe"
export DB_PASSWORD=`echo -n <DB_PASSWORD> | base64`
export ROOT_PASSWORD=`echo -n <ROOT_PASSWORD> | base64`

# Pod (Deployment) resource limits
export REQUEST_CPU="500m"
export REQUEST_MEMORY="1Gi"
export REQUEST_STORAGE="10Gi"
export LIMIT_CPU="500m"
export LIMIT_MEMORY="1Gi"
export LIMIT_STORAGE="20Gi"

# Storage
export STORAGE_DATA="8Gi"
export STORAGE_CLASS="nfs-client"

# High Priority Class 
export HIGH_PRIORITY_CLASS_NAME="high-priority"

sh ./deploy-mysql.sh