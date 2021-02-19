#!/bin/bash

echo ""
echo "Remove Elasticsearch using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"

kubectl delete secret elastic-certificates -n $NAMESPACE
kubectl delete secret $PREFIX-credentials -n $NAMESPACE
kubectl delete configmap $PREFIX-config -n $NAMESPACE
kubectl delete service $PREFIX -n $NAMESPACE
kubectl delete service $PREFIX-headless -n $NAMESPACE
kubectl delete statefulset $PREFIX -n $NAMESPACE
kubectl delete pvc $PREFIX-$PREFIX-0 -n $NAMESPACE
kubectl delete pvc $PREFIX-$PREFIX-1 -n $NAMESPACE
