#!/bin/bash

PROVISIONER_INDEX=$1

cat <<EOF | kubectl apply -f -
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: $STORAGE_NFS_PREFIX-storage-class-$PROVISIONER_INDEX
provisioner: $STORAGE_NFS_PREFIX-client-$PROVISIONER_INDEX # must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
EOF
