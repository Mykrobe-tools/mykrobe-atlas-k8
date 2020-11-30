#!/bin/bash

echo ""
echo "Deploying atlas api using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"
echo " - API Image: $API_IMAGE"
echo " - DB Host: $DB_SERVICE_HOST"
echo " - DB Replica Set name: $DB_RS_NAME"
echo " - AWS access key: $AWS_ACCESS_KEY"
echo " - AWS secret key: $AWS_SECRET_KEY"
echo " - AWS region: $AWS_REGION"
echo " - Atlas app: $ATLAS_APP"
echo ""
echo " - ES schema: $ES_SCHEME"
echo " - ES host: $ES_HOST"
echo " - ES port: $ES_PORT"
echo " - ES username: $ES_USERNAME"
echo " - ES password: $ES_PASSWORD"
echo " - ES index name: $ES_INDEX_NAME"
echo ""
echo " - Keycloak redirect URI: $KEYCLOAK_REDIRECT_URI"
echo " - Keycloak URI: $KEYCLOAK_URL"
echo " - Keycloak admin password: $KEYCLOAK_ADMIN_PASSWORD"
echo ""
echo " - API host: $API_HOST"
echo " - Analysis API: $ANALYSIS_API"
echo " - Bigsi API: $BIGSI_API"
echo " - Tracking API: $TRACKING_API"
echo " - Google geocoding API key: $GOOGLE_MAPS_API_KEY"
echo " - Swagger API files: $SWAGGER_API_FILES"
echo ""
echo " - Debug: $DEBUG"
echo " - Log Level: $LOG_LEVEL"
echo " - Elasticsearch Log Level: $ELASTICSEARCH_LOG_LEVEL"
echo ""
echo " - Forever dir: $FOREVER_DIR"
echo " - Forever log dir: $FOREVER_LOG_DIR"
echo " - Analysis API dir: $ANALYSIS_API_DIR"
echo " - Upload dir: $UPLOAD_DIR"
echo " - Uploads location: $UPLOADS_LOCATION"
echo " - Uploads temp location: $UPLOADS_TEMP_LOCATION"
echo " - Demo data folder: $DEMO_DATA_ROOT_FOLDER"
echo ""
echo " - Redis host: $REDIS_HOST"
echo " - Redis port: $REDIS_PORT"
echo ""
echo " - Cors origin: $CORS_ORIGIN"
echo ""
echo " - Groups job prefix: $GROUPS_JOB_PREFIX"
echo " - Groups job schedule: $GROUPS_JOB_SCHEDULE"
echo " - Groups location: $GROUPS_LOCATION"
echo ""

echo "Storage:"
echo " - Demo: $STORAGE_DEMO"
echo " - Uploads: $STORAGE_UPLOADS"
echo " - App data: $STORAGE_APP_DATA"
echo " - App tmp: $STORAGE_APP_TMP"
echo ""

echo "Limits:"
echo " - Request CPU: $REQUEST_CPU"
echo " - Request Memory: $REQUEST_MEMORY"
echo " - Request Storage: $REQUEST_STORAGE"
echo " - Limit CPU: $LIMIT_CPU"
echo " - Limit Memory: $LIMIT_MEMORY"
echo " - Limit Storage: $LIMIT_STORAGE"
echo ""

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: $PREFIX
  name: $PREFIX-sa
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: $PREFIX-tokenreview-binding
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: $PREFIX-sa
    namespace: $NAMESPACE
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PREFIX-uploads-data
  namespace: $NAMESPACE
spec:
  storageClassName: $STORAGE_CLASS
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: $STORAGE_UPLOADS
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PREFIX-groups-data
  namespace: $NAMESPACE
spec:
  storageClassName: $STORAGE_CLASS
  accessModes:
  - ReadWriteMany
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PREFIX-app-data
  namespace: $NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: $STORAGE_APP_DATA
  storageClassName: $STORAGE_CLASS
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PREFIX-app-tmp
  namespace: $NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: $STORAGE_APP_TMP
  storageClassName: $STORAGE_CLASS
---
apiVersion: v1
kind: Secret
metadata:
  name: $PREFIX-env-secret
  namespace: $NAMESPACE
data:
  AWS_ACCESS_KEY: $AWS_ACCESS_KEY
  AWS_SECRET_KEY: $AWS_SECRET_KEY
  ES_PASSWORD: $ES_PASSWORD
  KEYCLOAK_ADMIN_PASSWORD: $KEYCLOAK_ADMIN_PASSWORD
  GOOGLE_MAPS_API_KEY: $GOOGLE_MAPS_API_KEY
  MONGO_PASSWORD: $MONGO_PASSWORD
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    app: $PREFIX
  name: $PREFIX-deployment
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: $PREFIX
  template:
    metadata:
      labels:
        app: $PREFIX
      annotations:
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        runAsNonRoot: true
      serviceAccountName: $PREFIX-sa  
      containers:
      - image: $API_IMAGE
        name: $PREFIX
        readinessProbe:
          httpGet:
            path: /health-check
            port: 3000
          initialDelaySeconds: 120
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            path: /health-check
            port: 3000
          initialDelaySeconds: 130
          timeoutSeconds: 10
          failureThreshold: 10
        securityContext:
          runAsUser: 1000 
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
        ports:
        - containerPort: 3000
          protocol: TCP
        volumeMounts:
        - mountPath: $UPLOAD_DIR
          name: $PREFIX-uploads-volume
          readOnly: false 
        - mountPath: $FOREVER_DIR
          subPath: "forever"
          name: $PREFIX-app-data
          readOnly: false 
        - mountPath: $FOREVER_LOGS_DIR
          subPath: "logs"
          name: $PREFIX-app-data
          readOnly: false 
        - mountPath: $UPLOADS_TEMP_LOCATION
          name: $PREFIX-app-tmp
          readOnly: false
        - mountPath: $GROUPS_LOCATION
          name: $PREFIX-groups-volume
          readOnly: false
        env:
        - name: NODE_ENV
          value: production
        - name: DB_SERVICE_HOST
          value: $DB_SERVICE_HOST
        - name: DB_SERVICE_PORT
          value: '27017'
        - name: DB_RS_NAME
          value: $DB_RS_NAME
        - name: MONGO_USER
          value: $MONGO_USER
        - name: MONGO_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: MONGO_PASSWORD
        - name: AWS_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: AWS_ACCESS_KEY
        - name: AWS_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: AWS_SECRET_KEY
        - name: AWS_REGION
          value: $AWS_REGION
        - name: ATLAS_APP
          value: $ATLAS_APP
        - name: ES_SCHEME
          value: $ES_SCHEME
        - name: ES_HOST
          value: $ES_HOST
        - name: ES_PORT
          value: "$ES_PORT"
        - name: ES_USERNAME
          value: $ES_USERNAME
        - name: ES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: ES_PASSWORD
        - name: ES_INDEX_NAME
          value: $ES_INDEX_NAME
        - name: KEYCLOAK_REDIRECT_URI
          value: $KEYCLOAK_REDIRECT_URI
        - name: KEYCLOAK_URL
          value: $KEYCLOAK_URL
        - name: KEYCLOAK_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: KEYCLOAK_ADMIN_PASSWORD
        - name: API_HOST
          value: $API_HOST
        - name: DEBUG
          value: "$DEBUG"
        - name: LOG_LEVEL
          value: "$LOG_LEVEL"
        - name: ELASTICSEARCH_LOG_LEVEL
          value: "$ELASTICSEARCH_LOG_LEVEL"
        - name: ANALYSIS_API
          value: $ANALYSIS_API
        - name: BIGSI_API
          value: $BIGSI_API
        - name: TRACKING_API
          value: $TRACKING_API
        - name: ANALYSIS_API_DIR
          value: $ANALYSIS_API_DIR
        - name: UPLOAD_DIR
          value: $UPLOAD_DIR
        - name: UPLOADS_LOCATION
          value: $UPLOADS_LOCATION
        - name: UPLOADS_TEMP_LOCATION
          value: $UPLOADS_TEMP_LOCATION
        - name: DEMO_DATA_ROOT_FOLDER
          value: $DEMO_DATA_ROOT_FOLDER
        - name: GOOGLE_MAPS_API_KEY
          valueFrom:
            secretKeyRef:
              name: $PREFIX-env-secret
              key: GOOGLE_MAPS_API_KEY
        - name: SWAGGER_API_FILES
          value: $SWAGGER_API_FILES
        - name: REDIS_HOST
          value: $REDIS_HOST
        - name: REDIS_PORT
          value: '$REDIS_PORT'
        - name: NODE_OPTIONS
          value: '--max-old-space-size=$NODE_OPTIONS_MEMORY'
        - name: CORS_ORIGIN
          value: $CORS_ORIGIN
        - name: GROUPS_LOCATION
          value: $GROUPS_LOCATION 
        resources: 
          requests:
            memory: "$REQUEST_MEMORY"
            cpu: "$REQUEST_CPU" 
            ephemeral-storage: "$REQUEST_STORAGE"         
          limits:
            memory: "$LIMIT_MEMORY"
            cpu: "$LIMIT_CPU" 
            ephemeral-storage: "$LIMIT_STORAGE"
      volumes:
      - name: $PREFIX-uploads-volume
        persistentVolumeClaim:
          claimName: $PREFIX-uploads-data
      - name: $PREFIX-app-data
        persistentVolumeClaim:
          claimName: $PREFIX-app-data
      - name: $PREFIX-app-tmp
        persistentVolumeClaim:
          claimName: $PREFIX-app-tmp
      - name: $PREFIX-groups-volume
        persistentVolumeClaim:
          claimName: $PREFIX-groups-data
      imagePullSecrets:
      - name: gcr-json-key
---
apiVersion: v1
kind: Service
metadata:
  name: $PREFIX-service
  namespace: $NAMESPACE
spec:
  type: NodePort
  ports:
  - name: http
    port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    app: $PREFIX
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: $PREFIX-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/enable-cors: 'true'
    nginx.ingress.kubernetes.io/cors-allow-origin: $CORS_ORIGIN
    nginx.ingress.kubernetes.io/proxy-body-size: 10m
  namespace: $NAMESPACE
spec:
  backend:
    serviceName: $PREFIX-service
    servicePort: 3000
  tls:
  - hosts:
    - $API_HOST
    secretName: $PREFIX-mykro-be-tls
  rules:
  - host: $API_HOST
    http:
      paths:
      - backend:
          serviceName: $PREFIX-service
          servicePort: 3000
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: $GROUPS_JOB_PREFIX-cronjob
  namespace: $NAMESPACE
spec:
  schedule: $GROUPS_JOB_SCHEDULE
  failedJobsHistoryLimit: 1
  successfulJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: $PREFIX-sa
          containers:
          - name: $GROUPS_JOB_PREFIX-job
            image: ubuntu
            args:
            - /bin/bash
            - -c
            - curl -XPOST http://$PREFIX-service:3000/groups/search
          restartPolicy: OnFailure
      backoffLimit: 3
      activeDeadlineSeconds: 120
EOF