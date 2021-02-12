#!/bin/bash

echo ""
echo "Remove Atlas Client using:"
echo " - Namespace: $NAMESPACE"
echo " - Release Name: $RELEASE_NAME"

kubectl delete configmap $RELEASE_NAME-mongodb-replicaset-mongodb -n $NAMESPACE
kubectl delete secret $RELEASE_NAME-mongodb-secret -n $NAMESPACE
kubectl delete service $RELEASE_NAME-mongodb-replicaset-client -n $NAMESPACE
kubectl delete service $RELEASE_NAME-mongodb-replicaset -n $NAMESPACE
kubectl delete statefulset $RELEASE_NAME-mongodb-replicaset -n $NAMESPACE
kubectl delete pvc datadir-$RELEASE_NAME-mongodb-replicaset-0 -n $NAMESPACE
kubectl delete pvc datadir-$RELEASE_NAME-mongodb-replicaset-1 -n $NAMESPACE
kubectl delete pvc datadir-$RELEASE_NAME-mongodb-replicaset-2 -n $NAMESPACE
