#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $DISTANCE_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: $DISTANCE_PREFIX-deployment
  labels:
    app: $DISTANCE_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $DISTANCE_PREFIX
  template:
    metadata:
      labels:
        app: $DISTANCE_PREFIX
    spec:
      serviceAccountName: $DISTANCE_PREFIX-sa
      volumes:
      - name: $DISTANCE_PREFIX-data
        persistentVolumeClaim:
          claimName: $DISTANCE_PREFIX-data
      containers:
      - name: $DISTANCE_PREFIX
        image: $DISTANCE_API_IMAGE
        ports:
        - containerPort: 8080
        volumeMounts:
        - mountPath: "/data/databases"
          name: $DISTANCE_PREFIX-data
        resources:
          limits:
            memory: $LIMIT_MEMORY_DISTANCE
            cpu: $LIMIT_CPU_DISTANCE
          requests:
            memory: $REQUEST_MEMORY_DISTANCE
            cpu: $REQUEST_CPU_DISTANCE
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $DISTANCE_PREFIX-data
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
  name: $DISTANCE_PREFIX-service
  labels:
    app: $DISTANCE_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: $DISTANCE_PREFIX
EOF