#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $BACKGROUND_VARIANTS_DB_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: $BACKGROUND_VARIANTS_DB_PREFIX-deployment
  labels:
    app: $BACKGROUND_VARIANTS_DB_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $BACKGROUND_VARIANTS_DB_PREFIX
  template:
    metadata:
      labels:
        app: $BACKGROUND_VARIANTS_DB_PREFIX
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $BACKGROUND_VARIANTS_DB_PREFIX-sa
      volumes:
      - name: $BACKGROUND_VARIANTS_DB_PREFIX-data
        persistentVolumeClaim:
          claimName: $BACKGROUND_VARIANTS_DB_PREFIX-data
      containers:
      - name: $BACKGROUND_VARIANTS_DB_PREFIX
        image: $BACKGROUND_VARIANTS_DB_IMAGE
        ports:
        - containerPort: 27017
        volumeMounts:
        - mountPath: "/database"
          name: $BACKGROUND_VARIANTS_DB_PREFIX-data
        resources:
          limits:
            memory: $LIMIT_MEMORY_BACKGROUND_VARIANTS_DB
            cpu: $LIMIT_CPU_BACKGROUND_VARIANTS_DB
          requests:
            memory: $REQUEST_MEMORY_BACKGROUND_VARIANTS_DB
            cpu: $REQUEST_CPU_BACKGROUND_VARIANTS_DB
      priorityClassName: $HIGH_PRIORITY_CLASS_NAME
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $BACKGROUND_VARIANTS_DB_PREFIX-data
  namespace: $NAMESPACE
spec:
  storageClassName: external-nfs-provisioner-storage-class-4
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: $BACKGROUND_VARIANTS_DB_PREFIX-service
  labels:
    app: $BACKGROUND_VARIANTS_DB_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: $BACKGROUND_VARIANTS_DB_PREFIX
EOF