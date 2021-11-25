#!/bin/bash

export NAMESPACE="insight"
export PREFIX="mykrobe"
export METABASE_IMAGE="metabase/metabase:v0.36.6"
export DATABASE="metabase"
export DB_USER=`echo -n "mykrobe" | base64`
export DB_PASSWORD=`echo -n <UAT_MYSQL_PASSWORD> | base64` #secret
export DNS="insight-uat.mykro.be"
export APP_NAME="insight-uat"

# Pod (Deployment) resource limits
export REQUEST_CPU="500m"
export REQUEST_MEMORY="2Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="2Gi"
export LIMIT_STORAGE="4Gi"

sh ./deploy-metabase.sh