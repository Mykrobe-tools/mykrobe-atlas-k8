#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $KMERSEARCH_API_PREFIX-sa
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
        env:
        - name: COBS_INDEX_PATH
          value: /data/50000.cobs_compact
        resources:
          limits:
            memory: $LIMIT_MEMORY_KMERSEARCH_API
            cpu: $LIMIT_CPU_KMERSEARCH_API
          requests:
            memory: $REQUEST_MEMORY_KMERSEARCH_API
            cpu: $REQUEST_CPU_KMERSEARCH_API
        volumeMounts:
          - mountPath: "/data"
            name: $KMERSEARCH_API_PREFIX-data
      volumes:
        - name: $KMERSEARCH_API_PREFIX-data
          persistentVolumeClaim:
            claimName: cobs-data
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
EOF