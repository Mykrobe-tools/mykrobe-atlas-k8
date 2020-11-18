#!/bin/bash

export NAMESPACE="mykrobe-dev"
export TARGET_ENV="dev"
export ATLAS_API="https://api-dev.mykro.be"

export ATLAS_AUTH_REALM="atlas"
export ATLAS_AUTH_SERVER="https://accounts-dev.mykro.be/auth"
export ATLAS_AUTH_CLIENT_ID="analysis-api"
export ATLAS_AUTH_CLIENT_SECRET="66011b88-e780-4997-a518-b1b42bccdd1f"

export ANALYSIS_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-analysis-api:94e172a"
export ANALYSIS_API_WORKER_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-analysis-api-worker:94e172a"

export BIGSI_AGGREGATOR_IMAGE="zhichengliu/bigsi-ebi-api:b13a619"
export BIGSI_IMAGE="zhichengliu/bigsi:cb7ea44"

export DISTANCE_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-distance-api:512d921"
export NEO4J_IMAGE="neo4j:4.1"

export REDIS_IMAGE="redis:4.0"

export TRACKING_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-tracking-api:603c0aa"
export TRACKING_DB_IMAGE="postgres:12"

export REDIS_PREFIX="redis"
export ANALYSIS_PREFIX="analysis-api"
export BIGSI_PREFIX="bigsi-api"
export DISTANCE_PREFIX="distance-api"
export ATLAS_API_PREFIX="atlas-api"
export NEO4J_PREFIX="neo4j"
export TRACKING_API_PREFIX="tracking-api"
export TRACKING_DB_PREFIX="tracking-db"

export NEO4J_URI="bolt://neo4j-service:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="<password>"
export NEO4J_AUTH=`echo -n $NEO4J_USER/$NEO4J_PASSWORD | base64`
export DISTANCE_API_NEO4J_AUTH=`echo -n $NEO4J_USER:$NEO4J_PASSWORD | base64`

export TRACKING_DB_USER="postgres"
export TRACKING_DB_PASSWORD_RAW="password"
export TRACKING_DB_PASSWORD=`echo -n "$TRACKING_DB_PASSWORD_RAW" | base64`
export TRACKING_DB_SVC="$TRACKING_DB_PREFIX-service"
export TRACKING_DB_PORT="5432"
export TRACKING_DB_URI_RAW="postgresql://$TRACKING_DB_USER:$TRACKING_DB_PASSWORD_RAW@$TRACKING_DB_SVC:$TRACKING_DB_PORT"
export TRACKING_DB_URI=`echo -n "$TRACKING_DB_URI_RAW" | base64`

export POD_CPU_REDIS="500m"
export POD_MEMORY_REDIS="1Gi"
export REQUEST_MEMORY_ANALYSIS_API="1Gi"
export REQUEST_CPU_ANALYSIS_API="500m"
export LIMIT_MEMORY_ANALYSIS_API="1Gi"
export LIMIT_CPU_ANALYSIS_API="500m"
export REQUEST_MEMORY_ANALYSIS_WORKER="4Gi"
export REQUEST_CPU_ANALYSIS_WORKER="2000m"
export LIMIT_MEMORY_ANALYSIS_WORKER="4Gi"
export LIMIT_CPU_ANALYSIS_WORKER="2000m"
export REQUEST_MEMORY_BIGSI="2Gi"
export REQUEST_CPU_BIGSI="1000m"
export REQUEST_STORAGE_BIGSI="4Gi"
export LIMIT_MEMORY_BIGSI="2Gi"
export LIMIT_CPU_BIGSI="1000m"
export LIMIT_STORAGE_BIGSI="4Gi"
export REQUEST_MEMORY_DISTANCE="1Gi"
export REQUEST_CPU_DISTANCE="500m"
export LIMIT_MEMORY_DISTANCE="2Gi"
export LIMIT_CPU_DISTANCE="1000m"
export REQUEST_MEMORY_NEO4J="1Gi"
export REQUEST_CPU_NEO4J="500m"
export LIMIT_MEMORY_NEO4J="2Gi"
export LIMIT_CPU_NEO4J="500m"
export REQUEST_MEMORY_TRACKING_API="1Gi"
export REQUEST_CPU_TRACKING_API="500m"
export LIMIT_MEMORY_TRACKING_API="2Gi"
export LIMIT_CPU_TRACKING_API="1000m"
export REQUEST_MEMORY_TRACKING_DB="1Gi"
export REQUEST_CPU_TRACKING_DB="500m"
export LIMIT_MEMORY_TRACKING_DB="2Gi"
export LIMIT_CPU_TRACKING_DB="500m"

echo ""
echo "Deploying analysis api using:"
echo " - NAMESPACE: $NAMESPACE"
echo " - Target: $TARGET_ENV"
echo " - Atlas api prefix: $ATLAS_API_PREFIX"
echo " - Atlas Api: $ATLAS_API"

echo " - Atlas auth realm: $ATLAS_AUTH_REALM"
echo " - Atlas auth server: $ATLAS_AUTH_SERVER"
echo " - Atlas auth client ID: $ATLAS_ATLAS_AUTH_CLIENT_ID"
echo " - Atlas auth client secret: $ATLAS_ATLAS_AUTH_CLIENT_SECRET"

echo " - Analysis Prefix: $ANALYSIS_PREFIX"
echo " - Analysis API image: $ANALYSIS_API_IMAGE"
echo " - Analysis API worker image: $ANALYSIS_API_WORKER_IMAGE"

echo " - Bigsi Prefix: $BIGSI_PREFIX"
echo " - Bigsi aggregator image: $BIGSI_AGGREGATOR_IMAGE"
echo " - Bigsi image: $BIGSI_IMAGE"

echo " - Distance Prefix: $DISTANCE_PREFIX"
echo " - Distance api image: $DISTANCE_API_IMAGE"

echo " - Neo4J Prefix: $NEO4J_PREFIX"
echo " - Neo4J image: $NEO4J_IMAGE"
echo " - Neo4J username: $NEO4J_USER"
echo " - Neo4J password: $NEO4J_PASSWORD"
echo " - Neo4J URI: $NEO4J_URI"

echo " - Tracking Prefix: $TRACKING_API_PREFIX"
echo " - Tracking api image: $TRACKING_API_IMAGE"

echo " - Tracking database Prefix: $TRACKING_DB_PREFIX"
echo " - Tracking database image: $TRACKING_DB_IMAGE"
echo " - Tracking database hostname: $TRACKING_DB_SVC"
echo " - Tracking database port: $TRACKING_DB_PORT"
echo " - Tracking database user: $TRACKING_DB_USER"

echo " - Redis Prefix: $REDIS_PREFIX"
echo " - Redis image: $REDIS_IMAGE"
echo ""

echo "Limits:"
echo " - Redis Memory: $POD_MEMORY_REDIS"
echo " - Redis CPU: $POD_MEMORY_REDIS"

echo " - Analysis API Memory request: $REQUEST_MEMORY_ANALYSIS_API"
echo " - Analysis API CPU request: $REQUEST_CPU_ANALYSIS_API"
echo " - Analysis API Memory limit: $LIMIT_MEMORY_ANALYSIS_API"
echo " - Analysis API CPU limit: $LIMIT_CPU_ANALYSIS_API"

echo " - Analysis Worker Memory request: $REQUEST_MEMORY_ANALYSIS_WORKER"
echo " - Analysis Worker CPU request: $REQUEST_CPU_ANALYSIS_WORKER"
echo " - Analysis Worker Memory limit: $LIMIT_MEMORY_ANALYSIS_WORKER"
echo " - Analysis Worker CPU limit: $LIMIT_CPU_ANALYSIS_WORKER"

echo " - BIGSI Memory request: $REQUEST_MEMORY_BIGSI"
echo " - BIGSI CPU request: $REQUEST_CPU_BIGSI"
echo " - BIGSI Memory limit: $LIMIT_MEMORY_BIGSI"
echo " - BIGSI CPU limit: $LIMIT_CPU_BIGSI"

echo " - Distance Memory request: $REQUEST_MEMORY_DISTANCE"
echo " - Distance CPU request: $REQUEST_CPU_DISTANCE"
echo " - Distance Memory limit: $LIMIT_MEMORY_DISTANCE"
echo " - Distance CPU limit: $LIMIT_CPU_DISTANCE"

echo " - Neo4J Memory request: $REQUEST_MEMORY_NEO4J"
echo " - Neo4J CPU request: $REQUEST_CPU_NEO4J"
echo " - Neo4J Memory limit: $LIMIT_MEMORY_NEO4J"
echo " - Neo4J CPU limit: $LIMIT_CPU_NEO4J"
echo ""

echo " - Tracking API Memory request: $REQUEST_MEMORY_TRACKING_API"
echo " - Tracking API CPU request: $REQUEST_CPU_TRACKING_API"
echo " - Tracking API Memory limit: $LIMIT_MEMORY_TRACKING_API"
echo " - Tracking API CPU limit: $LIMIT_CPU_TRACKING_API"

echo " - Tracking database Memory request: $REQUEST_MEMORY_TRACKING_DB"
echo " - Tracking database CPU request: $REQUEST_CPU_TRACKING_DB"
echo " - Tracking database Memory limit: $LIMIT_MEMORY_TRACKING_DB"
echo " - Tracking database CPU limit: $LIMIT_CPU_TRACKING_DB"
echo ""

sh ./redis/deploy-redis.sh
sh ./analysis/deploy-analysis.sh
sh ./analysis/copy-files.sh
sh ./bigsi/deploy-bigsi.sh
sh ./distance/deploy-neo4j.sh
sh ./distance/deploy-distance.sh
sh ./tracking/deploy-tracking-db.sh
sh ./tracking/deploy-tracking-api.sh
