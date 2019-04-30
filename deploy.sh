#!/usr/bin/env bash

sed -i "s~#{image}~$ARTIFACT_IMAGE~g" atlas-deployment.json
sed -i "s~#{ATLAS_APP}~$ATLAS_APP~g" atlas-deployment.json
sed -i "s~#{API_URL}~$API_URL~g" atlas-deployment.json
sed -i "s~#{API_URL}~$API_URL~g" atlas-deployment.json
sed -i "s~#{AUTH_COOKIE_NAME}~$AUTH_COOKIE_NAME~g" atlas-deployment.json
sed -i "s~#{API_SWAGGER_URL}~$API_SWAGGER_URL~g" atlas-deployment.json
sed -i "s~#{GOOGLE_MAPS_API_KEY}~$GOOGLE_MAPS_API_KEY~g" atlas-deployment.json
sed -i "s~#{BOX_CLIENT_ID}~$BOX_CLIENT_ID~g" atlas-deployment.json
sed -i "s~#{DROPBOX_APP_KEY}~$DROPBOX_APP_KEY~g" atlas-deployment.json
sed -i "s~#{GOOGLE_DRIVE_CLIENT_ID}~$GOOGLE_DRIVE_CLIENT_ID~g" atlas-deployment.json
sed -i "s~#{GOOGLE_DRIVE_DEVELOPER_KEY}~$GOOGLE_DRIVE_DEVELOPER_KEY~g" atlas-deployment.json
sed -i "s~#{ONEDRIVE_CLIENT_ID}~$ONEDRIVE_CLIENT_ID~g" atlas-deployment.json
sed -i "s~#{GOOGLE_MAPS_API_KEY}~$GOOGLE_MAPS_API_KEY~g" atlas-deployment.json

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

echo "Artifact image $ARTIFACT_IMAGE"
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