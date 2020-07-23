#!/bin/bash

export NAMESPACE="mykrobe-dev"
export PREFIX="atlas-api"
export API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-api:v0.0.6"

export DB_SERVICE_HOST="mykrobe-mongodb-replicaset-client.mykrobe-dev.svc.cluster.local"
export DB_RS_NAME="rs0"
export MONGO_USER="atlas"
export MONGO_PASSWORD="<password>"

export AWS_ACCESS_KEY="<AWS_ACCESS_KEY>"
export AWS_SECRET_KEY="<AWS_SECRET_KEY>"
export AWS_REGION="eu-west-1"
export ATLAS_APP="https://dev.mykro.be"

export ES_SCHEME="https"
export ES_HOST="es-dev.makeandship.com"
export ES_PORT="9200"
export ES_USERNAME="admin"
export ES_PASSWORD="<ES_PASSWORD>"
export ES_INDEX_NAME="mykrobe-dev"

export KEYCLOAK_REDIRECT_URI="https://dev.mykro.be/"
export KEYCLOAK_URL="https://accounts.makeandship.com/auth"
export KEYCLOAK_ADMIN_PASSWORD="<KEYCLOAK_ADMIN_PASSWORD>"
export API_HOST="api-dev.mykro.be"
export DEBUG=1
export LOG_LEVEL=debug

export ANALYSIS_API="http://analysis-api-service.mykrobe-dev.svc.cluster.local"
export BIGSI_API="http://bigsi-api-aggregator-service.mykrobe-dev.svc.cluster.local"
export ANALYSIS_API_DIR="/data"
export UPLOAD_DIR="/home/node/app/uploads"
export UPLOADS_LOCATION="/home/node/data"
export UPLOADS_TEMP_LOCATION="/home/node/tmp"
export DEMO_DATA_ROOT_FOLDER="/home/node/app/demo"
export LOCATIONIQ_API_KEY="<LOCATIONIQ_API_KEY>"
export SWAGGER_API_FILES="/home/node/app/dist/server/routes/*.route.js"

# Storage sizes
export STORAGE_DEMO="8Gi"
export STORAGE_UPLOADS="50Gi"

# Pod (Deployment) resource limits
export REQUEST_CPU="1000m"
export REQUEST_MEMORY="8Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="8Gi"
export LIMIT_STORAGE="4Gi"
export NODE_OPTIONS_MEMORY="8192"

sh ./deploy-api.sh