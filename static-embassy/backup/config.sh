#!/bin/bash

export NAMESPACE="mykrobe-dev"
export PREFIX="backup"
export IMAGE="gcr.io/rightbreathe-app/bitbucket.org/makeandship/rightbreathe-backup:4c05c7b"
export DB_HOST="mykrobe-mongodb-replicaset-client.mykrobe-dev.svc"
export MONGO_USER="atlas"

sh ./deploy.sh