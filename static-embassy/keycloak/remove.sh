#!/bin/bash

echo ""
echo "Remove keycloak using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"
echo " - Postgres prefix: $POSTGRES_PREFIX"

kubectl delete secret $PREFIX-credentials-secret -n $NAMESPACE
kubectl delete service $POSTGRES_PREFIX-service -n $NAMESPACE
kubectl delete deployment $PREFIX-deployment -n $NAMESPACE
kubectl delete deployment $POSTGRES_PREFIX -n $NAMESPACE
kubectl delete ingress $PREFIX-ingress -n $NAMESPACE
kubectl delete service $PREFIX-service -n $NAMESPACE
kubectl delete ingress $PREFIX-ingress -n $NAMESPACE
kubectl delete pvc $PREFIX-theme-data -n $NAMESPACE
kubectl delete pvc $POSTGRES_PREFIX-data -n $NAMESPACE