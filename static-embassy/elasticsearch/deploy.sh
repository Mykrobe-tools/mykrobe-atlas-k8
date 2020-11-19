#!/bin/bash

echo ""
echo "Deploying mykrobe elasticsearch cluster using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"
echo " - Image: $IMAGE"
echo ""
echo " - Replicas: $REPLICAS"
echo " - Cluster Name: $CLUSTER_NAME"
echo ""
echo " - Request CPU: $REQUEST_CPU"
echo " - Request Memory: $REQUEST_MEMORY"
echo " - Limit CPU: $LIMIT_CPU"
echo " - Limit Memory: $LIMIT_MEMORY"
echo ""
echo " - Storage Size: $STORAGE_SIZE"
echo " - Storage Size: $STORAGE_CLASS"
echo ""
echo " - Username: $USERNAME"
echo " - Password: $PASSWORD"
echo ""

kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 -n $NAMESPACE

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: $PREFIX-credentials
  namespace: $NAMESPACE
type: Opaque
data:
  username: $USERNAME
  password: $PASSWORD
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $PREFIX-config
  namespace: $NAMESPACE
  labels:
    app: $PREFIX
data:
  elasticsearch.yml: |
    xpack.security.enabled: true
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: "$PREFIX-pdb"
  namespace: $NAMESPACE
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      app: "$PREFIX"
---
kind: Service
apiVersion: v1
metadata:
  name: $PREFIX
  namespace: $NAMESPACE
  labels:
    app: "$PREFIX"
spec:
  type: ClusterIP
  selector:
    app: "$PREFIX"
  ports:
  - name: http
    protocol: TCP
    port: 9200
  - name: transport
    protocol: TCP
    port: 9300
---
kind: Service
apiVersion: v1
metadata:
  name: $PREFIX-headless
  namespace: $NAMESPACE
  labels:
    app: "$PREFIX"
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  clusterIP: None # This is needed for statefulset hostnames like elasticsearch-0 to resolve
  # Create endpoints also if the related pod isn't ready
  publishNotReadyAddresses: true
  selector:
    app: "$PREFIX"
  ports:
  - name: http
    port: 9200
  - name: transport
    port: 9300
EOF

sed "s#{NAMESPACE}#$NAMESPACE#g" statefulset.yaml > statefulset-tmp0.yaml
sed "s#{PREFIX}#$PREFIX#g" statefulset-tmp0.yaml > statefulset-tmp1.yaml
sed "s#{IMAGE}#$IMAGE#g" statefulset-tmp1.yaml > statefulset-tmp2.yaml
sed "s#{REPLICAS}#$REPLICAS#g" statefulset-tmp2.yaml > statefulset-tmp3.yaml
sed "s#{CLUSTER_NAME}#$CLUSTER_NAME#g" statefulset-tmp3.yaml > statefulset-tmp4.yaml
sed "s#{REQUEST_CPU}#$REQUEST_CPU#g" statefulset-tmp4.yaml > statefulset-tmp5.yaml
sed "s#{REQUEST_MEMORY}#$REQUEST_MEMORY#g" statefulset-tmp5.yaml > statefulset-tmp6.yaml
sed "s#{LIMIT_CPU}#$LIMIT_CPU#g" statefulset-tmp6.yaml > statefulset-tmp7.yaml
sed "s#{LIMIT_MEMORY}#$LIMIT_MEMORY#g" statefulset-tmp7.yaml > statefulset-tmp8.yaml
sed "s#{STORAGE_SIZE}#$STORAGE_SIZE#g" statefulset-tmp8.yaml > statefulset-tmp9.yaml
sed "s#{STORAGE_CLASS}#$STORAGE_CLASS#g" statefulset-tmp9.yaml > statefulset-resolved.yaml

kubectl apply -f statefulset-resolved.yaml

rm statefulset-*