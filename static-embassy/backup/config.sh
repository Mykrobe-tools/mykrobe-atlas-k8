#!/bin/bash

export NAMESPACE="mykrobe-dev"
export PREFIX="backup"
export IMAGE="eu.gcr.io/atlas-275810/mykrobe-atlas-backup:52e6317"
export DB_HOST="mykrobe-mongodb-replicaset-client.mykrobe-dev.svc"
export MONGO_USER="atlas"
export DB_NAME="atlas"

sh ./deploy.sh