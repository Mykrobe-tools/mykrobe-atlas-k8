#!/bin/bash

export NAMESPACE="mykrobe-analysis-prod"
export TARGET_ENV="prod"
export ATLAS_API="https://api.mykro.be"
export ANALYSIS_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-analysis-api:e2e488d"
export BIGSI_AGGREGATOR_IMAGE="phelimb/bigsi-aggregator:210419"
export BIGSI_IMAGE="zhichengliu/bigsi:cb7ea44"
export DISTANCE_PREFIX="distance-api"
export DISTANCE_API_IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-distance-api:v0.0.1"
export REDIS_IMAGE="redis:4.0"

export REDIS_PREFIX="redis"
export ANALYSIS_PREFIX="analysis-api"
export BIGSI_PREFIX="bigsi-api"
export DISTANCE_PREFIX="distance-api"
export ATLAS_API_PREFIX="atlas-api"
export NEO4J_PREFIX="neo4j"
export NEO4J_IMAGE="neo4j:4.1"

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
export LIMIT_CPU_DISTANCE="500m"
export REQUEST_MEMORY_NEO4J="1Gi"
export REQUEST_CPU_NEO4J="500m"
export LIMIT_MEMORY_NEO4J="2Gi"
export LIMIT_CPU_NEO4J="500m"

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

echo " - Neo4J Prefix: $NEO4J_PREFIX"
echo " - Neo4J image: $NEO4J_IMAGE"

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

sh ./redis/deploy-redis.sh
sh ./analysis/deploy-analysis.sh
sh ./analysis/copy-files.sh $(kubectl get pods --selector=app=analysis-api-worker -n mykrobe-dev -o jsonpath="{.items[0].metadata.name}") $NAMESPACE
sh ./bigsi/deploy-bigsi.sh
sh ./distance/deploy-distance.sh
sh ./distance/deploy-neo4j.sh