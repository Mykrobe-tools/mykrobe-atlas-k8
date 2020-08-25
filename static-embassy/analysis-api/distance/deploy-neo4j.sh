#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $NEO4J_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: $NEO4J_PREFIX-deployment
  labels:
    app: $NEO4J_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $NEO4J_PREFIX
  template:
    metadata:
      labels:
        app: $NEO4J_PREFIX
    spec:
      serviceAccountName: $NEO4J_PREFIX-sa
      volumes:
      - name: $NEO4J_PREFIX-data
        persistentVolumeClaim:
          claimName: $NEO4J_PREFIX-data
      containers:
      - name: $NEO4J_PREFIX
        image: $NEO4J_IMAGE
        ports:
        - containerPort: 7687
        volumeMounts:
        - mountPath: "/data/databases"
          name: $NEO4J_PREFIX-data
        env:
        - name: NEO4J_AUTH
          value: $NEO4J_AUTH
        resources:
          limits:
            memory: $LIMIT_MEMORY_NEO4J
            cpu: $LIMIT_CPU_NEO4J
          requests:
            memory: $REQUEST_MEMORY_NEO4J
            cpu: $REQUEST_CPU_NEO4J
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $NEO4J_PREFIX-data
  namespace: $NAMESPACE
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: $NEO4J_PREFIX-service
  labels:
    app: $NEO4J_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: 7687
    targetPort: 7687
  selector:
    app: $NEO4J_PREFIX
EOF