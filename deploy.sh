#!/usr/bin/env bash

# --------------------------------------------------------------
# Automated deployment using the kubernetes API:

# - Client: Deployment
# - Client: Service
# - Client: Ingress (not autodeployed or used)
# --------------------------------------------------------------

sed -i "s~#{ARTIFACT_IMAGE}~$DOCKERHUB_ORGANISATION/atlas-client:$GO_DEPENDENCY_LABEL_BUILD~g" atlas-api-deployment.json

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

# --------------------------------------------------------------

echo
echo "Deploying Client"
echo 

# --------------------------------------------------------------

echo "Artifact image $DOCKERHUB_ORGANISATION/atlas-client:$GO_DEPENDENCY_LABEL_BUILD"
echo "Namespace $NAMESPACE"
echo "Service Host $KUBERNETES_SERVICE_HOST"
echo "Port $KUBERNETES_PORT_443_TCP_PORT"

# --------------------------------------------------------------

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/deployments/atlas-deployment" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Atlas deployment: $status_code"

if [ $status_code == 200 ]; then
  echo "Updating Atlas deployment"
  curl -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/deployments/atlas-deployment" \
    -X PATCH -d @atlas-deployment.json
else
 echo
 echo "Creating Atlas deployment"
 curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/deployments" \
    -X POST -d @atlas-deployment.json
fi

echo

# --------------------------------------------------------------

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/atlas-service" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Atlas service: $status_code"

if [ $status_code == 200 ]; then
 echo "Updating Atlas service"
 echo

 curl -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/atlas-service" \
    -X PATCH -d @atlas-service.json
else
  echo "Updating Atlas service"
  echo
  curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services" \
    -X POST -d @atlas-service.json
fi

echo

# --------------------------------------------------------------

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/atlas-ingress" \
    -X GET -o /dev/null -w "%{http_code}")

echo
echo "Atlas Ingress: $status_code"

if [ $status_code == 200 ]; then
 echo "Updating ingress"
 echo

 curl -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/atlas-ingress" \
    -X PATCH -d @atlas-ingress.json
else
 echo "Creating ingress"
 echo

 curl -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses" \
    -X POST -d @atlas-ingress.json
fi

echo