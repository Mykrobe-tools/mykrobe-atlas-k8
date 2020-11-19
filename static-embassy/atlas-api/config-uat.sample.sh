#!/bin/bash

export NAMESPACE="mykrobe"
export PREFIX="atlas-api"
export API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-api:adeebc6"

export DB_SERVICE_HOST="mykrobe-mongodb-replicaset-client.mykrobe.svc.cluster.local"
export DB_RS_NAME="rs0"

export AWS_ACCESS_KEY="<AWS_ACCESS_KEY>"
export AWS_SECRET_KEY="<AWS_SECRET_KEY>"
export AWS_REGION="eu-west-1"
export ATLAS_APP="https://uat.mykro.be"

export ES_SCHEME="http"
export ES_HOST="mykrobe-elasticsearch-headless.search-uat.svc"
export ES_PORT="9200"
export ES_USERNAME="elastic"
export ES_PASSWORD=`echo -n "<ES_PASSWORD>" | base64`
export ES_INDEX_NAME="mykrobe-uat"

export KEYCLOAK_REDIRECT_URI="https://uat.mykro.be/"
export KEYCLOAK_URL="https://accounts-uat.mykro.be/auth"
export KEYCLOAK_ADMIN_PASSWORD="<KEYCLOAK_ADMIN_PASSWORD>"
export API_HOST="api-uat.mykro.be"
export DEBUG=1
export LOG_LEVEL=debug
export CORS_ORIGIN="uat.mykro.be"

export ANALYSIS_API="http://analysis-api-service.mykrobe.svc.cluster.local"
export BIGSI_API="http://bigsi-api-aggregator-service.mykrobe.svc.cluster.local"
export TRACKING_API="http://tracking-api-service.mykrobe.svc.cluster.local/api/v1"
export GOOGLE_MAPS_API_KEY=`echo -n "" | base64`
export SWAGGER_API_FILES="/home/node/app/dist/server/routes/*.route.js"

export FOREVER_DIR="/home/node/data/forever"
export FOREVER_LOGS_DIR="/home/node/data/logs"
export ANALYSIS_API_DIR="/data"
export UPLOAD_DIR="/home/node/app/uploads"
export UPLOADS_LOCATION="/home/node/data"
export UPLOADS_TEMP_LOCATION="/home/node/tmp"
export DEMO_DATA_ROOT_FOLDER="/home/node/app/demo"

export REDIS_HOST="redis.mykrobe.svc.cluster.local"
export REDIS_PORT="6379"

# Storage sizes
export STORAGE_DEMO="8Gi"
export STORAGE_UPLOADS="50Gi"
export STORAGE_APP_DATA="10Gi"
export STORAGE_APP_TMP="5Gi"

# Storage class
export STORAGE_CLASS="nfs-client"

# Groups job
export GROUPS_JOB_PREFIX="groups-search"
export GROUPS_JOB_SCHEDULE="0 0 * * *"

# Pod (Deployment) resource limits
export REQUEST_CPU="1000m"
export REQUEST_MEMORY="4Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="4Gi"
export LIMIT_STORAGE="4Gi"
export NODE_OPTIONS_MEMORY="4096"

sh ./deploy-api.sh