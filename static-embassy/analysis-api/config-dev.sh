#!/bin/bash

export NAMESPACE="mykrobe-dev"
export ATLAS_API="https://api-dev.mykro.be"

export ANALYSIS_API_IMAGE="phelimb/mykrobe-atlas-analysis-api:113af42"
export ANALYSIS_CONFIG_HASH_MD5="0960112ac0a45b542a3c77aea5f2ceb4"
export ANALYSIS_API_DNS="analysis-dev.mykro.be"

export BIGSI_AGGREGATOR_IMAGE="phelimb/bigsi-aggregator:210419"
export BIGSI_CONFIG_HASH_MD5="8240ad548481b94901c8052723816e27"
export BIGSI_IMAGE="phelimb/bigsi:v0.3.5"
export BIGSI_DNS="bigsi-dev.mykro.be"

export REDIS_IMAGE="redis:4.0"

export REDIS_PREFIX="redis"
export ANALYSIS_PREFIX="analysis-api"
export BIGSI_PREFIX="bigsi-api"
export ATLAS_API_PREFIX="atlas-api"

export POD_CPU_REDIS="1000m"
export POD_MEMORY_REDIS="1Gi"
export REQUEST_MEMORY_ANALYSIS="1Gi"
export REQUEST_CPU_ANALYSIS="1000m"
export LIMIT_MEMORY_ANALYSIS="2Gi"
export LIMIT_CPU_ANALYSIS="1000m"
export REQUEST_MEMORY_BIGSI="1Gi"
export REQUEST_CPU_BIGSI="1000m"
export REQUEST_STORAGE_BIGSI="4Gi"
export LIMIT_MEMORY_BIGSI="2Gi"
export LIMIT_CPU_BIGSI="1000m"
export LIMIT_STORAGE_BIGSI="4Gi"

echo ""
echo "Deploying analysis api using:"
echo " - NAMESPACE: $NAMESPACE"
echo " - Atlas api prefix: $ATLAS_API_PREFIX"
echo " - Atlas Api: $ATLAS_API"

echo " - Analysis Prefix: $ANALYSIS_PREFIX"
echo " - Analysis image: $ANALYSIS_API_IMAGE"
echo " - Analysis config hash: $ANALYSIS_CONFIG_HASH_MD5"
echo " - DNS: $ANALYSIS_API_DNS"

echo " - Bigsi Prefix: $BIGSI_PREFIX"
echo " - Bigsi aggregator image: $BIGSI_AGGREGATOR_IMAGE"
echo " - Bigsi image: $BIGSI_IMAGE"
echo " - Bigsi config hash: $BIGSI_CONFIG_HASH_MD5"
echo " - Bigsi dns: $BIGSI_DNS"

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
echo ""

sh ./redis/deploy-redis.sh
sh ./analysis/deploy-analysis.sh
sh ./bigsi/deploy-bigsi.sh