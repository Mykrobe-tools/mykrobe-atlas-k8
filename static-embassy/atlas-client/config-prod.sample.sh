#!/bin/bash

export NAMESPACE="mykrobe"
export PREFIX="atlas"
export CLIENT_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas:a81d112"
export HOST="www.mykro.be"
export ADDITIONAL_DNS="mykro.be"
export NODE_OPTIONS_MEMORY="4096"

# Pod (Deployment) resource limits
export REQUEST_CPU="1000m"
export REQUEST_MEMORY="1Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="1Gi"
export LIMIT_STORAGE="4Gi"

# Storage class
export STORAGE_DATA="2Gi"
export STORAGE_CLASS="external-nfs-provisioner-storage-class-2"

# Env vars

# Endpoint of the API
export REACT_APP_API_URL="https://api.mykro.be"

# Swagger spec if available
export REACT_APP_API_SPEC_URL="https://api.mykro.be/swagger.json"

# If using Keycloak
export REACT_APP_KEYCLOAK_URL="https://accounts.mykro.be/auth"
export REACT_APP_KEYCLOAK_REALM="atlas"
export REACT_APP_KEYCLOAK_CLIENT_ID="react-web-client"
export REACT_APP_KEYCLOAK_IDP=

# Provider upload keys
export REACT_APP_GOOGLE_MAPS_API_KEY=`echo -n <REACT_APP_GOOGLE_MAPS_API_KEY> | base64` #secret
export REACT_APP_BOX_CLIENT_ID=`echo -n <REACT_APP_BOX_CLIENT_ID>  | base64` #secret
export REACT_APP_DROPBOX_APP_KEY=`echo -n <REACT_APP_DROPBOX_APP_KEY>  | base64` #secret
export REACT_APP_GOOGLE_DRIVE_CLIENT_ID=`echo -n <REACT_APP_GOOGLE_DRIVE_CLIENT_ID> | base64` #secret
export REACT_APP_GOOGLE_DRIVE_DEVELOPER_KEY=`echo -n <REACT_APP_GOOGLE_DRIVE_DEVELOPER_KEY> | base64` #secret
export REACT_APP_ONEDRIVE_CLIENT_ID=`echo -n <REACT_APP_ONEDRIVE_CLIENT_ID>  | base64` #secret

# Crash telemetry
export REACT_APP_SENTRY_PUBLIC_DSN=`echo -n <REACT_APP_SENTRY_PUBLIC_DSN> | base64` #secret 

sh ./deploy-client.sh