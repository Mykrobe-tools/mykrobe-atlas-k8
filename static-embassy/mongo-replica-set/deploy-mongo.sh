#!/bin/bash

echo ""
echo "Deploying mongo using:"
echo " - Image: $MONGO_IMAGE"
echo " - Namespace: $NAMESPACE"
echo " - Release: $RELEASE_NAME"
echo " - Replicas: $REPLICAS"
echo " - User: $MONGO_USER"
echo " - Password: $MONGO_PASSWORD"
echo " - App DB: $APP_DB"
echo " - App User: $APP_USER"
echo " - App Password: $APP_PASSWORD"
echo " - Key: $MONGO_KEY"
echo ""

echo "Limits:"
echo " - Request CPU: $REQUEST_CPU"
echo " - Request Memory: $REQUEST_MEMORY"
echo " - Request Storage: $REQUEST_STORAGE"
echo " - Limit CPU: $LIMIT_CPU"
echo " - Limit Memory: $LIMIT_MEMORY"
echo " - Limit Storage: $LIMIT_STORAGE"
echo ""

kubectl apply -f mongodb-init-configmap.yaml -n $NAMESPACE

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: mongodb-replicaset
  name: $RELEASE_NAME-mongo-sa
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  mongod.conf: |
    {}
kind: ConfigMap
metadata:
  labels:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  name: $RELEASE_NAME-mongodb-replicaset-mongodb
  namespace: $NAMESPACE
---
apiVersion: v1
data:
  key.txt: $MONGO_KEY
  password: $MONGO_PASSWORD
  user: $MONGO_USER
  app_user: $APP_USER
  app_password: $APP_PASSWORD
kind: Secret
metadata:
  labels:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  name: $RELEASE_NAME-mongodb-secret
  namespace: $NAMESPACE
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  annotations: null
  labels:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  name: $RELEASE_NAME-mongodb-replicaset-client
  namespace: $NAMESPACE
spec:
  clusterIP: None
  ports:
  - name: mongodb
    port: 27017
  selector:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
  labels:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  name: $RELEASE_NAME-mongodb-replicaset
  namespace: $NAMESPACE
spec:
  clusterIP: None
  ports:
  - name: mongodb
    port: 27017
  publishNotReadyAddresses: true
  selector:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  type: ClusterIP
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: mongodb-replicaset
    release: $RELEASE_NAME
  name: $RELEASE_NAME-mongodb-replicaset
  namespace: $NAMESPACE
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: mongodb-replicaset
      release: $RELEASE_NAME
  serviceName: $RELEASE_NAME-mongodb-replicaset
  template:
    metadata:
      annotations:
        checksum/config: aefdcd6191ba1431beacf13834fede80e015dea465ab21a7e73d1eaa8c70ea51
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "mongo"
        vault.hashicorp.com/agent-inject-secret-db-creds: "database/creds/mongo"
      labels:
        app: mongodb-replicaset
        release: $RELEASE_NAME
    spec:
      serviceAccountName: $RELEASE_NAME-mongo-sa
      containers:
      - args:
        - --config=/data/configdb/mongod.conf
        - --dbpath=/data/db
        - --replSet=rs0
        - --port=27017
        - --bind_ip=0.0.0.0
        - --auth
        - --keyFile=/data/configdb/key.txt
        command:
        - mongod
        image: $MONGO_IMAGE
        imagePullPolicy: IfNotPresent
        livenessProbe:
          exec:
            command:
            - mongo
            - --eval
            - db.adminCommand('ping')
          failureThreshold: 3
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        name: mongodb-replicaset
        ports:
        - containerPort: 27017
          name: mongodb
        readinessProbe:
          exec:
            command:
            - mongo
            - --eval
            - db.adminCommand('ping')
          failureThreshold: 3
          initialDelaySeconds: 5
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources: 
          requests:
            memory: "$REQUEST_MEMORY"
            cpu: "$REQUEST_CPU" 
            ephemeral-storage: "$REQUEST_STORAGE"         
          limits:
            memory: "$LIMIT_MEMORY"
            cpu: "$LIMIT_CPU" 
            ephemeral-storage: "$LIMIT_STORAGE"
        volumeMounts:
        - mountPath: /data/db
          name: datadir
        - mountPath: /data/configdb
          name: configdir
        - mountPath: /work-dir
          name: workdir
      initContainers:
      - args:
        - -c
        - |
          set -e
          set -x

          cp /configdb-readonly/mongod.conf /data/configdb/mongod.conf
          cp /keydir-readonly/key.txt /data/configdb/key.txt
          chmod 600 /data/configdb/key.txt
        command:
        - sh
        image: busybox:1.29.3
        imagePullPolicy: IfNotPresent
        name: copy-config
        resources: {}
        volumeMounts:
        - mountPath: /work-dir
          name: workdir
        - mountPath: /configdb-readonly
          name: config
        - mountPath: /data/configdb
          name: configdir
        - mountPath: /keydir-readonly
          name: keydir
      - args:
        - --work-dir=/work-dir
        image: unguiculus/mongodb-install:0.7
        imagePullPolicy: IfNotPresent
        name: install
        resources: {}
        volumeMounts:
        - mountPath: /work-dir
          name: workdir
      - args:
        - -on-start=/init/on-start.sh
        - -service=$RELEASE_NAME-mongodb-replicaset
        command:
        - /work-dir/peer-finder
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        - name: REPLICA_SET
          value: rs0
        - name: TIMEOUT
          value: "900"
        - name: SKIP_INIT
          value: "false"
        - name: TLS_MODE
          value: requireSSL
        - name: AUTH
          value: "true"
        - name: APP_DB
          value: $APP_DB
        - name: ADMIN_USER
          valueFrom:
            secretKeyRef:
              key: user
              name: $RELEASE_NAME-mongodb-secret
        - name: ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              key: password
              name: $RELEASE_NAME-mongodb-secret
        - name: APP_USER
          valueFrom:
            secretKeyRef:
              key: app_user
              name: $RELEASE_NAME-mongodb-secret
        - name: APP_PASSWORD
          valueFrom:
            secretKeyRef:
              key: app_password
              name: $RELEASE_NAME-mongodb-secret
        image: $MONGO_IMAGE
        imagePullPolicy: IfNotPresent
        name: bootstrap
        resources: {}
        volumeMounts:
        - mountPath: /work-dir
          name: workdir
        - mountPath: /init
          name: init
        - mountPath: /data/configdb
          name: configdir
        - mountPath: /data/db
          name: datadir
      securityContext:
        fsGroup: 999
        runAsNonRoot: true
        runAsUser: 999
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          name: $RELEASE_NAME-mongodb-replicaset-mongodb
        name: config
      - configMap:
          defaultMode: 493
          name: mongodb-replicaset-init
        name: init
      - name: keydir
        secret:
          defaultMode: 256
          secretName: $RELEASE_NAME-mongodb-secret
      - emptyDir: {}
        name: workdir
      - emptyDir: {}
        name: configdir
  volumeClaimTemplates:
  - metadata:
      annotations: null
      name: datadir
    spec:
      storageClassName: nfs-client
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi

EOF