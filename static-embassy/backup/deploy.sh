#!/bin/bash

echo ""
echo "Deploying backup cron job using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"
echo " - Image: $IMAGE"
echo " - Database Host: $DB_HOST"
echo " - Database User: $MONGO_USER"
echo ""

# website
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
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: $PREFIX
  name: backup-cron-job
  namespace: $NAMESPACE
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: $PREFIX-sa
          containers:
          - name: backup-job
            image: $IMAGE
            env:
              - name: DB_HOST
                value: $DB_HOST
              - name: DB_PORT
                value: '27017'
              - name: MONGO_USER
                 value: $MONGO_USER
              - name: MONGO_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: atlas-api-env-secret
                    key: MONGO_PASSWORD
            args:
            - /bin/bash
            - -c
            - cd /home/ubuntu; ls; bash backup.sh;
          restartPolicy: OnFailure
      backoffLimit: 3
      activeDeadlineSeconds: 120
EOF