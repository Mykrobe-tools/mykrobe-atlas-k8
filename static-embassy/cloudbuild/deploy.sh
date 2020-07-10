#!/bin/bash

echo ""
echo "Deploying atlas api using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: $PREFIX
  name: $PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $PREFIX-clusterrole
rules:
- apiGroups: ["extensions", "apps"]
  resources: ["deployments","statefulsets"]
  verbs: ["patch","get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $PREFIX-binding
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $PREFIX-clusterrole
subjects:
- name: $PREFIX-sa
  apiGroup: 
  kind: ServiceAccount
  namespace: $NAMESPACE
EOF