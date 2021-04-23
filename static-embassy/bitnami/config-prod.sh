#!/bin/bash

export NAMESPACE="insight"
export PREFIX="mykrobe"
export BITNAMI="$PREFIX-bitnami"
export KAFDROP="$PREFIX-kafdrop"
export ZOOKEEPER="zookeeper"
export SCHEMA_REGISTRY="schema-registry"
export KAFKA_CONNECT="kafka-connect"
export KAFKA="kafka"
export KAFDROP_IMAGE="obsidiandynamics/kafdrop:3.27.0"
export KAFKA_CONNECT_IMAGE="makeandship/kafka-connect"
export SCHEMA_REGISTRY_IMAGE="confluentinc/cp-schema-registry:5.4.1"
export KAFKA_BROKER_IMAGE="docker.io/bitnami/kafka:2.8.0-debian-10-r0"
export ZOOKEEPER_IMAGE="docker.io/bitnami/zookeeper:3.7.0-debian-10-r0"

# Pod (Deployment) resource limits
export REQUEST_ZOOKEEPER_CPU="500m"
export REQUEST_ZOOKEEPER_MEMORY="1Gi"
export REQUEST_ZOOKEEPER_STORAGE="50Gi"
export LIMIT_ZOOKEEPER_CPU="1000m"
export LIMIT_ZOOKEEPER_MEMORY="1Gi"
export LIMIT_ZOOKEEPER_STORAGE="100Gi"
export ZOOKEEPER_EPHERMERAL_STORAGE="4Gi"

export REQUEST_KAFKA_CPU="1000m"
export REQUEST_KAFKA_MEMORY="2Gi"
export REQUEST_KAFKA_STORAGE="50Gi"
export LIMIT_KAFKA_CPU="2000m"
export LIMIT_KAFKA_MEMORY="4Gi"
export LIMIT_KAFKA_STORAGE="100Gi"
export KAFKA_EPHERMERAL_STORAGE="4Gi"

export REQUEST_SCHEMA_REGISTRY_CPU="500m"
export REQUEST_SCHEMA_REGISTRY_MEMORY="1Gi"
export LIMIT_SCHEMA_REGISTRY_CPU="1000m"
export LIMIT_SCHEMA_REGISTRY_MEMORY="1Gi"

export REQUEST_KAFKA_CONNECT_CPU="1000m"
export REQUEST_KAFKA_CONNECT_MEMORY="1Gi"
export LIMIT_KAFKA_CONNECT_CPU="2000m"
export LIMIT_KAFKA_CONNECT_MEMORY="2Gi"

export STORAGE_CLASS="external-nfs-provisioner-storage-class-4"

sh ./deploy-kafka.sh