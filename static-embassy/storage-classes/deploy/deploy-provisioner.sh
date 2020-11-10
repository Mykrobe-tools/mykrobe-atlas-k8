#!/bin/bash

PROVISIONER_INDEX=$1
PROVISIONER_SERVER_VARIABLE_NAME="STORAGE_NFS_SERVER_$PROVISIONER_INDEX"
PROVISIONER_SERVER=${!PROVISIONER_SERVER_VARIABLE_NAME}

cat <<EOF | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $STORAGE_NFS_PREFIX-deployment-$PROVISIONER_INDEX
  labels:
    app: $STORAGE_NFS_PREFIX-deployment-$PROVISIONER_INDEX
  namespace: $STORAGE_NAMESPACE
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: $STORAGE_NFS_PREFIX-deployment-$PROVISIONER_INDEX
  template:
    metadata:
      labels:
        app: $STORAGE_NFS_PREFIX-deployment-$PROVISIONER_INDEX
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $STORAGE_NFS_PREFIX-sa
      containers:
        - name: $STORAGE_NFS_PREFIX-container
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: $STORAGE_NFS_PREFIX-client-$PROVISIONER_INDEX
            - name: NFS_SERVER
              value: $PROVISIONER_SERVER
            - name: NFS_PATH
              value: $STORAGE_NFS_PATH
      volumes:
        - name: nfs-client-root
          nfs:
            server: $PROVISIONER_SERVER
            path: $STORAGE_NFS_PATH
EOF
