#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $ANALYSIS_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  ATLAS_API: $ATLAS_API
  ATLAS_AUTH_REALM: $ATLAS_AUTH_REALM
  ATLAS_AUTH_SERVER: $ATLAS_AUTH_SERVER
  ATLAS_AUTH_CLIENT_ID: $ATLAS_AUTH_CLIENT_ID
  ATLAS_AUTH_CLIENT_SECRET: $ATLAS_AUTH_CLIENT_SECRET
  KMERSEARCH_API_URL: http://$KMERSEARCH_API_PREFIX-service/api/v1
  BIGSI_URL: http://$BIGSI_PREFIX-aggregator-service/api/v1
  BIGSI_BUILD_URL: http://$BIGSI_PREFIX-service-small
  BIGSI_BUILD_CONFIG: /etc/bigsi/conf/config.yaml
  CELERY_BROKER_URL: redis://$REDIS_PREFIX:6379
  CLUSTER_DB_PATH: /data/cluster/cluster-cache-db
  DEFAULT_OUTDIR: /data/out/
  SKELETON_DIR: /config/
  FLASK_DEBUG: "1"
  REDIS_HOST: $REDIS_PREFIX
  REDIS_PORT: "6379"
  GENBANK_FILEPATH: /config/NC_000962.3.gb
  REFERENCE_FILEPATH: /config/NC_000962.3.fasta
  TB_TREE_PATH_V1: /config/tb_tree.txt
kind: ConfigMap
metadata:
  name: $ANALYSIS_PREFIX-env
  namespace: $NAMESPACE
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $ANALYSIS_PREFIX-config-data
  namespace: $NAMESPACE
spec:
  storageClassName: rwx-storage
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $ANALYSIS_PREFIX
  name: $ANALYSIS_PREFIX-service
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8001
  selector:
    app: $ANALYSIS_PREFIX
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: $ANALYSIS_PREFIX-worker
  name: $ANALYSIS_PREFIX-worker
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $ANALYSIS_PREFIX-worker
  template:
    metadata:
      labels:
        app: $ANALYSIS_PREFIX-worker
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $ANALYSIS_PREFIX-sa
      containers:
      - args:
        - -A
        - app.celery
        - worker
        - -O
        - fair
        - -l
        - DEBUG
        - --concurrency=4
        command:
        - celery
        env:
        - name: CONFIG_HASH_MD5
          value: $ANALYSIS_CONFIG_HASH_MD5
        envFrom:
        - configMapRef:
            name: $ANALYSIS_PREFIX-env
        image: $ANALYSIS_API_WORKER_IMAGE
        imagePullPolicy: IfNotPresent
        name: $ANALYSIS_PREFIX-worker
        volumeMounts:
        - mountPath: /data/
          name: uploads-data
        - mountPath: /config/
          name: $ANALYSIS_PREFIX-config-data
        resources:
          limits:
            memory: $LIMIT_MEMORY_ANALYSIS_WORKER
            cpu: $LIMIT_CPU_ANALYSIS_WORKER
          requests:
            memory: $REQUEST_MEMORY_ANALYSIS_WORKER
            cpu: $REQUEST_CPU_ANALYSIS_WORKER
      volumes:
      - name: uploads-data
        persistentVolumeClaim:
          claimName: $ATLAS_API_PREFIX-uploads-data
      - name: $ANALYSIS_PREFIX-config-data
        persistentVolumeClaim:
          claimName: $ANALYSIS_PREFIX-config-data
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: $ANALYSIS_PREFIX
  name: $ANALYSIS_PREFIX
  namespace: $NAMESPACE
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: $ANALYSIS_PREFIX
  template:
    metadata:
      labels:
        app: $ANALYSIS_PREFIX
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $ANALYSIS_PREFIX-sa
      containers:
      - args:
        - -c
        - uwsgi --enable-threads --socket 0.0.0.0:8001 --protocol=http  --harakiri 300  --buffer-size=65535  -w wsgi:app
        command:
        - /bin/sh
        env:
        - name: CONFIG_HASH_MD5
          value: $ANALYSIS_CONFIG_HASH_MD5
        envFrom:
        - configMapRef:
            name: $ANALYSIS_PREFIX-env
        image: $ANALYSIS_API_IMAGE
        imagePullPolicy: IfNotPresent
        name: $ANALYSIS_PREFIX
        ports:
        - containerPort: 8001
          protocol: TCP
        volumeMounts:
        - mountPath: /data/
          name: uploads-data
        - mountPath: /config/
          name: $ANALYSIS_PREFIX-config-data
        resources:
          limits:
            memory: $LIMIT_MEMORY_ANALYSIS_API
            cpu: $LIMIT_CPU_ANALYSIS_API
          requests:
            memory: $REQUEST_MEMORY_ANALYSIS_API
            cpu: $REQUEST_CPU_ANALYSIS_API
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      volumes:
      - name: uploads-data
        persistentVolumeClaim:
          claimName: $ATLAS_API_PREFIX-uploads-data
      - name: $ANALYSIS_PREFIX-config-data
        persistentVolumeClaim:
          claimName: $ANALYSIS_PREFIX-config-data
      imagePullSecrets:
      - name: gcr-json-key
EOF