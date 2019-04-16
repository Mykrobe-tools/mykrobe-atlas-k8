#!/usr/bin/env bash

sed -i "s~#{image}~$ARTIFACT_IMAGE~g" atlas-deployment.json

if [ -z $KUBE_TOKEN ]; then
  echo "FATAL: Environment Variable KUBE_TOKEN must be specified."
  exit ${2:-1}
fi

if [ -z $NAMESPACE ]; then
  echo "FATAL: Environment Variable NAMESPACE must be specified."
  exit ${2:-1}
fi

if [ -z $KUBERNETES_SERVICE_HOST ]; then
  echo "FATAL: Environment Variable KUBERNETES_SERVICE_HOST must be specified."
  exit ${2:-1}
fi

if [ -z $KUBERNETES_PORT_443_TCP_PORT ]; then
  echo "FATAL: Environment Variable KUBERNETES_PORT_443_TCP_PORT must be specified."
  exit ${2:-1}
fi

echo
echo "Deploying Client"
echo 
echo "Artifact image $ARTIFACT_IMAGE"
echo "Namespace $NAMESPACE"
echo "Service Host $KUBERNETES_SERVICE_HOST"
echo "Port $KUBERNETES_PORT_443_TCP_PORT"

echo
echo "Calling ... GET https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/atlas-deployment"

curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/atlas-deployment" \
    -X GET

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/atlas-deployment" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Result $status_code"

if [ $status_code == 200 ]; then
  echo
  echo "Updating deployment"
  curl -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/atlas-deployment" \
    -X PATCH -d @atlas-deployment.json
else
 echo
 echo "Creating deployment"
 curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments" \
    -X POST -d @atlas-deployment.json
fi

echo
echo "Calling ... GET https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/atlas-service"
curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/atlas-service" -X GET

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/atlas-service" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Result $status_code"

if [ $status_code == 404 ]; then
 echo
 echo "Creating service"
 curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services" \
    -X POST -d @atlas-service.json
fi

echo
echo "Calling ... GET https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/atlas-ingress"
curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/atlas-ingress" -X GET 

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/atlas-ingress" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Result $status_code"

if [ $status_code == 404 ]; then
 echo
 echo "Creating ingress"
 curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses" \
    -X POST -d @atlas-ingress.json
fi