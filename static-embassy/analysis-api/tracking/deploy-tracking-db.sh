#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $TRACKING_DB_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  POSTGRES_PASSWORD: $TRACKING_DB_PASSWORD
kind: Secret
metadata:
  labels:
    app: $TRACKING_DB_PREFIX
  name: $TRACKING_DB_PREFIX-secret
  namespace: $NAMESPACE
type: Opaque
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $TRACKING_DB_PREFIX-deployment
  labels:
    app: $TRACKING_DB_PREFIX
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $TRACKING_DB_PREFIX
  template:
    metadata:
      labels:
        app: $TRACKING_DB_PREFIX
    spec:
      serviceAccountName: $TRACKING_DB_PREFIX-sa
      volumes:
      - name: $TRACKING_DB_PREFIX-data
        persistentVolumeClaim:
          claimName: $TRACKING_DB_PREFIX-data
      initContainers:
      - args:
        - -c
        - chmod a+w /var/lib/postgresql/data
        command:
        - sh
        image: busybox:1.29.3
        imagePullPolicy: IfNotPresent
        name: change-permission
        volumeMounts:
        - mountPath: "/var/lib/postgresql/data"
          name: $TRACKING_DB_PREFIX-data
      containers:
      - name: $TRACKING_DB_PREFIX
        image: $TRACKING_DB_IMAGE
        securityContext:
          runAsUser: 1000
          runAsGroup: 1000
          runAsNonRoot: true
        ports:
        - containerPort: $TRACKING_DB_PORT
        volumeMounts:
        - mountPath: "/var/lib/postgresql/data"
          name: $TRACKING_DB_PREFIX-data
        env:
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        - name: POSTGRES_USER
          value: $TRACKING_DB_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              key: POSTGRES_PASSWORD
              name: $TRACKING_DB_PREFIX-secret
        resources:
          limits:
            memory: $LIMIT_MEMORY_TRACKING_DB
            cpu: $LIMIT_CPU_TRACKING_DB
          requests:
            memory: $REQUEST_MEMORY_TRACKING_DB
            cpu: $REQUEST_CPU_TRACKING_DB
      priorityClassName: $HIGH_PRIORITY_CLASS_NAME
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $TRACKING_DB_PREFIX-data
  namespace: $NAMESPACE
spec:
  storageClassName: default-cinder
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 4Gi
---
apiVersion: v1
kind: Service
metadata:
  name: $TRACKING_DB_SVC
  labels:
    app: $TRACKING_DB_PREFIX
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - port: $TRACKING_DB_PORT
    targetPort: $TRACKING_DB_PORT
  selector:
    app: $TRACKING_DB_PREFIX
EOF