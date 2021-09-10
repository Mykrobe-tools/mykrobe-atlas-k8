#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $KMERSEARCH_API_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  COBS_CLASSIC_INDEXES_DIR: /cobs/classic
  TB_REF: /config/NC_000962.3.fasta
kind: ConfigMap
metadata:
  name: $KMERSEARCH_API_PREFIX-env
  namespace: $NAMESPACE
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: $KMERSEARCH_API_PREFIX-deployment
  labels:
    app: $KMERSEARCH_API_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $KMERSEARCH_API_PREFIX
  template:
    metadata:
      labels:
        app: $KMERSEARCH_API_PREFIX
    spec:
      serviceAccountName: $KMERSEARCH_API_PREFIX-sa
      containers:
      - name: $KMERSEARCH_API_PREFIX
        image: $KMERSEARCH_API_IMAGE
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: $KMERSEARCH_API_PREFIX-env
        resources:
          limits:
            memory: $LIMIT_MEMORY_KMERSEARCH_API
            cpu: $LIMIT_CPU_KMERSEARCH_API
          requests:
            memory: $REQUEST_MEMORY_KMERSEARCH_API
            cpu: $REQUEST_CPU_KMERSEARCH_API
        volumeMounts:
          - mountPath: "/cobs"
            name: $KMERSEARCH_API_PREFIX-data
          - mountPath: /config/
            name: $ANALYSIS_PREFIX-config-data
          - mountPath: /data/
            name: uploads-data
      volumes:
        - name: $KMERSEARCH_API_PREFIX-data
          persistentVolumeClaim:
            claimName: $KMERSEARCH_API_PREFIX-data
        - name: $ANALYSIS_PREFIX-config-data
          persistentVolumeClaim:
            claimName: $ANALYSIS_PREFIX-config-data
        - name: uploads-data
          persistentVolumeClaim:
            claimName: $ATLAS_API_PREFIX-uploads-data
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: v1
kind: Service
metadata:
  name: $KMERSEARCH_API_PREFIX-service
  labels:
    app: $KMERSEARCH_API_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8000
  selector:
    app: $KMERSEARCH_API_PREFIX
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $KMERSEARCH_API_PREFIX-data
  namespace: $NAMESPACE
spec:
  storageClassName: external-nfs-provisioner-storage-class-1
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 256Gi
EOF