#!/bin/bash

export NAMESPACE="mykrobe-dev"
export ATLAS_API="https://api-dev.mykro.be"

export ANALYSIS_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-analysis-api:50e3dd1"

export BIGSI_AGGREGATOR_IMAGE="phelimb/bigsi-aggregator:210419"
export BIGSI_IMAGE="phelimb/bigsi:v0.3.5"

export DISTANCE_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-distance-api:v0.0.1"

export REDIS_IMAGE="redis:4.0"

export REDIS_PREFIX="redis"
export ANALYSIS_PREFIX="analysis-api"
export BIGSI_PREFIX="bigsi-api"
export DISTANCE_PREFIX="distance-api"
export ATLAS_API_PREFIX="atlas-api"

export POD_CPU_REDIS="500m"
export POD_MEMORY_REDIS="1Gi"
export REQUEST_MEMORY_ANALYSIS="2Gi"
export REQUEST_CPU_ANALYSIS="500m"
export LIMIT_MEMORY_ANALYSIS="2Gi"
export LIMIT_CPU_ANALYSIS="500m"
export REQUEST_MEMORY_BIGSI="1Gi"
export REQUEST_CPU_BIGSI="500m"
export REQUEST_STORAGE_BIGSI="4Gi"
export LIMIT_MEMORY_BIGSI="1Gi"
export LIMIT_CPU_BIGSI="500m"
export LIMIT_STORAGE_BIGSI="4Gi"
export REQUEST_MEMORY_DISTANCE="1Gi"
export REQUEST_CPU_DISTANCE="1000m"
export LIMIT_MEMORY_DISTANCE="2Gi"
export LIMIT_CPU_DISTANCE="1000m"

echo ""
echo "Deploying analysis api using:"
echo " - NAMESPACE: $NAMESPACE"
echo " - Atlas api prefix: $ATLAS_API_PREFIX"
echo " - Atlas Api: $ATLAS_API"

echo " - Analysis Prefix: $ANALYSIS_PREFIX"
echo " - Analysis image: $ANALYSIS_API_IMAGE"

echo " - Bigsi Prefix: $BIGSI_PREFIX"
echo " - Bigsi aggregator image: $BIGSI_AGGREGATOR_IMAGE"
echo " - Bigsi image: $BIGSI_IMAGE"

echo " - Distance Prefix: $DISTANCE_PREFIX"
echo " - Distance api image: $DISTANCE_API_IMAGE"

echo " - Redis Prefix: $REDIS_PREFIX"
echo " - Redis image: $REDIS_IMAGE"
echo ""

echo "Limits:"
echo " - Redis Memory: $POD_MEMORY_REDIS"
echo " - Redis CPU: $POD_MEMORY_REDIS"

echo " - Analysis Memory request: $REQUEST_MEMORY_ANALYSIS"
echo " - Analysis CPU request: $REQUEST_CPU_ANALYSIS"
echo " - Analysis Memory limit: $LIMIT_MEMORY_ANALYSIS"
echo " - Analysis CPU limit: $LIMIT_CPU_ANALYSIS"

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