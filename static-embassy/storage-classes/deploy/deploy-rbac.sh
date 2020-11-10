#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $STORAGE_NFS_PREFIX-sa
  namespace: $STORAGE_NAMESPACE
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $STORAGE_NFS_PREFIX-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $STORAGE_NFS_PREFIX-cluster-role-binding
subjects:
  - kind: ServiceAccount
    name: $STORAGE_NFS_PREFIX-sa
    namespace: $STORAGE_NAMESPACE
roleRef:
  kind: ClusterRole
  name: $STORAGE_NFS_PREFIX-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $STORAGE_NFS_PREFIX-role
  namespace: $STORAGE_NAMESPACE
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $STORAGE_NFS_PREFIX-role-binding
  namespace: $STORAGE_NAMESPACE
subjects:
  - kind: ServiceAccount
    name: $STORAGE_NFS_PREFIX-sa
    namespace: $STORAGE_NAMESPACE
roleRef:
  kind: Role
  name: $STORAGE_NFS_PREFIX-role
  apiGroup: rbac.authorization.k8s.io
EOF
