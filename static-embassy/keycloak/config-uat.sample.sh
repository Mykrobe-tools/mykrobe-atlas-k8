#!/bin/bash

export NAMESPACE="mykrobe"
export PREFIX="keycloak"
export POSTGRES_PREFIX="postgres"
export POSTGRES_IMAGE="postgres:10"
export KEYCLOAK_IMAGE="makeandship/keycloak:1"
export HOST="accounts-uat.mykro.be"
export POSTGRES_DB="keycloak"
export POSTGRES_USER=`echo -n "keycloak" | base64`
export POSTGRES_PASSWORD=`echo -n "<POSTGRES_PASSWORD>" | base64`
export DB_ADDR="postgres-service"
export DB_PORT="5432"
export KEYCLOAK_USER=`echo -n "admin" | base64`
export KEYCLOAK_PASSWORD=`echo -n "<KEYCLOAK_PASSWORD>" | base64`

# Storage sizes
export STORAGE_POSTGRES="10Gi"
export STORAGE_THEMES="2Gi"

# Pod (Deployment) resource limits
export REQUEST_DB_CPU="1000m"
export REQUEST_DB_MEMORY="4Gi"
export REQUEST_DB_STORAGE="2Gi"
export LIMIT_DB_CPU="1000m"
export LIMIT_DB_MEMORY="4Gi"
export LIMIT_DB_STORAGE="4Gi"

export REQUEST_CPU="1000m"
export REQUEST_MEMORY="4Gi"
export REQUEST_STORAGE="2Gi"
export LIMIT_CPU="1000m"
export LIMIT_MEMORY="4Gi"
export LIMIT_STORAGE="4Gi"

sh ./deploy-keycloak.sh