#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $TRACKING_API_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  SQLALCHEMY_DATABASE_URI: $TRACKING_DB_URI
kind: Secret
metadata:
  labels:
    app: $TRACKING_API_PREFIX
  name: $TRACKING_API_PREFIX-secret
  namespace: $NAMESPACE
type: Opaque
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: $TRACKING_API_PREFIX-deployment
  labels:
    app: $TRACKING_API_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $TRACKING_API_PREFIX
  template:
    metadata:
      labels:
        app: $TRACKING_API_PREFIX
    spec:
      serviceAccountName: $TRACKING_API_PREFIX-sa
      containers:
      - name: $TRACKING_API_PREFIX
        image: $TRACKING_API_IMAGE
        ports:
        - containerPort: 8080
        env:
        - name: SQLALCHEMY_DATABASE_URI
          valueFrom:
            secretKeyRef:
              key: SQLALCHEMY_DATABASE_URI
              name: $TRACKING_API_PREFIX-secret
        resources:
          limits:
            memory: $LIMIT_MEMORY_TRACKING_API
            cpu: $LIMIT_CPU_TRACKING_API
          requests:
            memory: $REQUEST_MEMORY_TRACKING_API
            cpu: $REQUEST_CPU_TRACKING_API
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: v1
kind: Service
metadata:
  name: $TRACKING_API_PREFIX-service
  labels:
    app: $TRACKING_API_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: $TRACKING_API_PREFIX
EOF