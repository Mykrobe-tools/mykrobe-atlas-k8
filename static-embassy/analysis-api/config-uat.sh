#!/bin/bash

export NAMESPACE="mykrobe-analysis-uat"
export TARGET_ENV="uat"
export ATLAS_API="https://api-uat.mykro.be"
export ANALYSIS_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-analysis-api:e2e488d"
export BIGSI_IMAGE="zhichengliu/bigsi:cb7ea44"
export BIGSI_IMAGE="phelimb/bigsi:v0.3.5"
export DISTANCE_PREFIX="distance-api"
export DISTANCE_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-distance-api:v0.0.1"
export REDIS_IMAGE="redis:4.0"

export POD_CPU_REDIS="1000m"
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
export LIMIT_CPU_DISTANCE="500m"

echo ""
echo "Deploying analysis api using:"
echo " - NAMESPACE: $NAMESPACE"
echo " - Target: $TARGET_ENV"
echo " - Atlas Api: $ATLAS_API"
echo " - Analysis image: $ANALYSIS_API_IMAGE"
echo " - Bigsi aggregator image: $BIGSI_AGGREGATOR_IMAGE"
echo " - Bigsi image: $BIGSI_IMAGE"
echo " - Distance Prefix: $DISTANCE_PREFIX"
echo " - Distance api image: $DISTANCE_API_IMAGE"
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
echo ""

sh ./redis/deploy-redis.sh
sh ./analysis/deploy-analysis.sh
sh ./analysis/copy-files.sh $(kubectl get pods --selector=app=analysis-api-worker -n mykrobe-dev -o jsonpath="{.items[0].metadata.name}") $NAMESPACE
sh ./bigsi/deploy-bigsi.sh
sh ./distance/deploy-distance.sh