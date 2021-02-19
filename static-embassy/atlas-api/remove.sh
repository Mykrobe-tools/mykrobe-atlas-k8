#!/bin/bash

echo ""
echo "Remove Atlas API using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"

kubectl delete secret $PREFIX-env-secret -n $NAMESPACE
kubectl delete deployment $PREFIX-deployment -n $NAMESPACE
kubectl delete service $PREFIX-service -n $NAMESPACE
kubectl delete service $PREFIX-ingress -n $NAMESPACE
kubectl delete pvc $PREFIX-uploads-data -n $NAMESPACE
kubectl delete pvc $PREFIX-groups-data -n $NAMESPACE
kubectl delete pvc $PREFIX-app-data -n $NAMESPACE
kubectl delete pvc $PREFIX-app-tmp -n $NAMESPACE

