echo ""
echo "Deploying atlas api using:"
echo " - Namespace: $NAMESPACE"
echo " - Name: $NAME"
echo " - Version: $VERSION"
echo ""

echo "Cloudflare:"
echo " - Notification Email: $CLOUDFLARE_NOTIFICATION_EMAIL"
echo " - Account Email: $CLOUDFLARE_ACCOUNT_EMAIL"
echo ""

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOF

helm install $NAME \
  --namespace $NAMESPACE \
  --version v0.15.1 \
  --set installCRDs=true \
  jetstack/cert-manager 

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
  namespace: $NAMESPACE
type: Opaque
data:
  api-key: $CLOUDFLARE_API_KEY
---
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $CLOUDFLARE_NOTIFICATION_EMAIL

    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: account-key-letsencrypt-prod

    # ACME DNS-01 provider configurations
    solvers:
      - dns01:
          cloudflare:
            email: $CLOUDFLARE_ACCOUNT_EMAIL
            apiKeySecretRef:
              name: cloudflare-api-key
              key: api-key
EOF