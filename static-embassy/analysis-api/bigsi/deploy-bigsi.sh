#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $BIGSI_PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $BIGSI_PREFIX-data
  namespace: $NAMESPACE
spec:
  storageClassName: external-nfs-provisioner-storage-class-1
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 512Gi
---
apiVersion: v1
data:
  ATLAS_API: $ATLAS_API
  BIGSI_URLS: http://$BIGSI_PREFIX-service-big http://$BIGSI_PREFIX-service-small
  REDIS_HOST: $REDIS_PREFIX
  REDIS_IP: $REDIS_PREFIX
  REDIS_PORT: "6379"
kind: ConfigMap
metadata:
  name: $BIGSI_PREFIX-aggregator-env
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  BIGSI_CONFIG: /etc/bigsi/conf/config.yaml
kind: ConfigMap
metadata:
  name: $BIGSI_PREFIX-env
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  config.yaml: |-
    h: 1
    k: 31
    m: 28000000
    nproc: 1
    storage-engine: berkeleydb
    storage-config:
      filename: /database/big-bigsi-bdb
      flag: "r" ## Change to 'c' for write access
kind: ConfigMap
metadata:
  name: $BIGSI_PREFIX-config-big
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  config.yaml: |-
    h: 1
    k: 31
    m: 28000000
    nproc: 1
    storage-engine: berkeleydb
    storage-config:
      filename: /database/small-bigsi-bdb
      flag: "c" ## Change to 'r' for read-only access
kind: ConfigMap
metadata:
  name: $BIGSI_PREFIX-config-small
  namespace: $NAMESPACE
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: $BIGSI_PREFIX-aggregator
    tier: front
  name: $BIGSI_PREFIX-aggregator-deployment
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $BIGSI_PREFIX-aggregator
  template:
    metadata:
      labels:
        app: $BIGSI_PREFIX-aggregator
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $BIGSI_PREFIX-sa
      containers:
      - args:
        - -c
        - uwsgi --harakiri 300  --buffer-size=65535 --socket 0.0.0.0:8001 --protocol=http -w wsgi
        command:
        - /bin/sh
        envFrom:
        - configMapRef:
            name: $BIGSI_PREFIX-aggregator-env
        image: $BIGSI_AGGREGATOR_IMAGE
        imagePullPolicy: IfNotPresent
        name: $BIGSI_PREFIX-aggregator
        resources:
          limits:
            memory: $LIMIT_MEMORY_BIGSI
            cpu: $LIMIT_CPU_BIGSI
            ephemeral-storage: "$LIMIT_STORAGE_BIGSI"
          requests:
            memory: $REQUEST_MEMORY_BIGSI
            cpu: $REQUEST_CPU_BIGSI
            ephemeral-storage: "$REQUEST_STORAGE_BIGSI"
        ports:
        - containerPort: 8001
          protocol: TCP
      dnsPolicy: ClusterFirst
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $BIGSI_PREFIX-aggregator
  name: $BIGSI_PREFIX-aggregator-service
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8001
  selector:
    app: $BIGSI_PREFIX-aggregator
  sessionAffinity: None
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: $BIGSI_PREFIX-aggregator-worker
    tier: front
  name: $BIGSI_PREFIX-aggregator-worker
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $BIGSI_PREFIX-aggregator-worker
  template:
    metadata:
      labels:
        app: $BIGSI_PREFIX-aggregator-worker
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $BIGSI_PREFIX-sa
      containers:
      - args:
        - -A
        - bigsi_aggregator.celery
        - worker
        - --concurrency=4
        command:
        - celery
        envFrom:
        - configMapRef:
            name: $BIGSI_PREFIX-aggregator-env
        image: $BIGSI_AGGREGATOR_IMAGE
        imagePullPolicy: IfNotPresent
        name: $BIGSI_PREFIX-aggregator-worker
        resources:
          limits:
            memory: $LIMIT_MEMORY_BIGSI
            cpu: $LIMIT_CPU_BIGSI
            ephemeral-storage: "$LIMIT_STORAGE_BIGSI"
          requests:
            memory: $REQUEST_MEMORY_BIGSI
            cpu: $REQUEST_CPU_BIGSI
            ephemeral-storage: "$REQUEST_STORAGE_BIGSI" 
      dnsPolicy: ClusterFirst
      restartPolicy: Always
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: $BIGSI_PREFIX-big
    tier: front
  name: $BIGSI_PREFIX-deployment-big
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $BIGSI_PREFIX-big
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: $BIGSI_PREFIX-big
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $BIGSI_PREFIX-sa
      containers:
        - args:
          - -c
          - uwsgi --enable-threads --socket 0.0.0.0:8001 --protocol=http --wsgi-file bigsi/__main__.py --callable
            __hug_wsgi__ --processes=4 --buffer-size=32768 --harakiri=300000
          command:
          - /bin/sh
          envFrom:
          - configMapRef:
              name: $BIGSI_PREFIX-env
          image: $BIGSI_IMAGE
          imagePullPolicy: IfNotPresent
          name: $BIGSI_PREFIX-big
          ports:
          - containerPort: 8001
            protocol: TCP
          volumeMounts:
          - mountPath: /config/
            name: $ANALYSIS_PREFIX-config-data
          - mountPath: /database/
            name: $BIGSI_PREFIX-data-big
          - mountPath: /etc/bigsi/conf/
            name: configmap-volume-big
          resources:
            limits:
              memory: $LIMIT_MEMORY_BIGSI
              cpu: $LIMIT_CPU_BIGSI
              ephemeral-storage: "$LIMIT_STORAGE_BIGSI"
            requests:
              memory: $REQUEST_MEMORY_BIGSI
              cpu: $REQUEST_CPU_BIGSI
              ephemeral-storage: "$REQUEST_STORAGE_BIGSI"   
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      volumes:
      - name: $ANALYSIS_PREFIX-config-data
        persistentVolumeClaim:
          claimName: $ANALYSIS_PREFIX-config-data
      - name: $BIGSI_PREFIX-data-big
        persistentVolumeClaim:
          claimName: $BIGSI_PREFIX-data
      - configMap:
          defaultMode: 420
          name: $BIGSI_PREFIX-config-big
        name: configmap-volume-big
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: $BIGSI_PREFIX-small
    tier: front
  name: $BIGSI_PREFIX-deployment-small
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $BIGSI_PREFIX-small
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: $BIGSI_PREFIX-small
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $BIGSI_PREFIX-sa
      containers:
        - args:
          - -c
          - uwsgi --enable-threads --socket 0.0.0.0:8001 --protocol=http --wsgi-file bigsi/__main__.py --callable
            __hug_wsgi__ --processes=4 --buffer-size=32768 --harakiri=300000
          command:
          - /bin/sh
          envFrom:
          - configMapRef:
              name: $BIGSI_PREFIX-env
          image: $BIGSI_IMAGE
          imagePullPolicy: IfNotPresent
          name: $BIGSI_PREFIX-small
          ports:
          - containerPort: 8001
            protocol: TCP
          volumeMounts:
          - mountPath: /config/
            name: $ANALYSIS_PREFIX-config-data
          - mountPath: /data/
            name: uploads-data
          - mountPath: /database/
            name: $BIGSI_PREFIX-data-small
          - mountPath: /etc/bigsi/conf/
            name: configmap-volume-small
          resources:
            limits:
              memory: $LIMIT_MEMORY_BIGSI
              cpu: $LIMIT_CPU_BIGSI
              ephemeral-storage: "$LIMIT_STORAGE_BIGSI"
            requests:
              memory: $REQUEST_MEMORY_BIGSI
              cpu: $REQUEST_CPU_BIGSI
              ephemeral-storage: "$REQUEST_STORAGE_BIGSI"
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      volumes:
      - name: $ANALYSIS_PREFIX-config-data
        persistentVolumeClaim:
          claimName: $ANALYSIS_PREFIX-config-data
      - name: uploads-data
        persistentVolumeClaim:
          claimName: $ATLAS_API_PREFIX-uploads-data
      - name: $BIGSI_PREFIX-data-small
        persistentVolumeClaim:
          claimName: $BIGSI_PREFIX-data
      - configMap:
          defaultMode: 420
          name: $BIGSI_PREFIX-config-small
        name: configmap-volume-small
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $BIGSI_PREFIX-big
  name: $BIGSI_PREFIX-service-big
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8001
  selector:
    app: $BIGSI_PREFIX-big
  sessionAffinity: None
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $BIGSI_PREFIX-small
  name: $BIGSI_PREFIX-service-small
  namespace: $NAMESPACE
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8001
  selector:
    app: $BIGSI_PREFIX-small
  sessionAffinity: None
  type: NodePort
EOF