#!/bin/bash

echo ""
echo "Deploying Kafka platform using:"
echo " - Namespace: $NAMESPACE"
echo " - Prefix: $PREFIX"
echo " - Bitnami: $BITNAMI"
echo " - Kafdrop: $KAFDROP"
echo " - Zookeeper: $ZOOKEEPER"
echo " - Schema Registry: $SCHEMA_REGISTRY"
echo " - Kafka Connect: $KAFKA_CONNECT"
echo " - Kafka: $KAFKA"
echo " - Kafdrop Image: $KAFDROP_IMAGE"
echo " - Kafka-connect Image: $KAFKA_CONNECT_IMAGE"
echo " - Schema-registry Image: $SCHEMA_REGISTRY_IMAGE"
echo " - Kafka broker Image: $KAFKA_BROKER_IMAGE"
echo " - Zookeeper Image: $ZOOKEEPER_IMAGE"
echo ""


echo "Limits:"
echo " - Request Zookeeper CPU: $REQUEST_ZOOKEEPER_CPU"
echo " - Request Zookeeper Memory: $REQUEST_ZOOKEEPER_MEMORY"
echo " - Request Zookeeper Storage: $REQUEST_ZOOKEEPER_STORAGE"
echo " - Limit Zookeeper CPU: $LIMIT_ZOOKEEPER_CPU"
echo " - Limit Zookeeper Memory: $LIMIT_ZOOKEEPER_MEMORY"
echo " - Limit Zookeeper Storage: $LIMIT_ZOOKEEPER_STORAGE"
echo " - Zookeeper Ephermeral Storage: $ZOOKEEPER_EPHERMERAL_STORAGE"
echo " - Request Broker CPU: $REQUEST_KAFKA_CPU"
echo " - Request Broker Memory: $REQUEST_KAFKA_MEMORY"
echo " - Request Broker Storage: $REQUEST_KAFKA_STORAGE"
echo " - Limit Broker CPU: $LIMIT_KAFKA_CPU"
echo " - Limit Broker Memory: $LIMIT_KAFKA_MEMORY"
echo " - Limit Broker Storage: $LIMIT_KAFKA_STORAGE"
echo " - Request Schema Registry CPU: $REQUEST_SCHEMA_REGISTRY_CPU"
echo " - Request Schema Registry Memory: $REQUEST_SCHEMA_REGISTRY_MEMORY"
echo " - Limit Schema Registry CPU: $LIMIT_SCHEMA_REGISTRY_CPU"
echo " - Limit Schema Registry Memory: $LIMIT_SCHEMA_REGISTRY_MEMORY"
echo " - Request Connect CPU: $REQUEST_KAFKA_CONNECT_CPU"
echo " - Request Connect Memory: $REQUEST_KAFKA_CONNECT_MEMORY"
echo " - Limit Connect CPU: $LIMIT_KAFKA_CONNECT_CPU"
echo " - Limit Connect Memory: $LIMIT_KAFKA_CONNECT_MEMORY"
echo ""

echo "Storage:"
echo " - Storage Class: $STORAGE_CLASS"
echo ""

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: $BITNAMI
  name: $PREFIX-insight
  namespace: $NAMESPACE
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$ZOOKEEPER-headless
  namespace: $NAMESPACE
  labels:
    app.kubernetes.io/name: $ZOOKEEPER
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $ZOOKEEPER
spec:
  type: ClusterIP
  clusterIP: None
  publishNotReadyAddresses: true
  ports:
    
    - name: tcp-client
      port: 2181
      targetPort: client
    
    
    - name: follower
      port: 2888
      targetPort: follower
    - name: tcp-election
      port: 3888
      targetPort: election
  selector:
    app.kubernetes.io/name: $ZOOKEEPER
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $ZOOKEEPER
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$ZOOKEEPER
  namespace: $NAMESPACE
  labels:
    app.kubernetes.io/name: $ZOOKEEPER
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $ZOOKEEPER
spec:
  type: ClusterIP
  ports:
    
    - name: tcp-client
      port: 2181
      targetPort: client
    
    
    - name: follower
      port: 2888
      targetPort: follower
    - name: tcp-election
      port: 3888
      targetPort: election
  selector:
    app.kubernetes.io/name: $ZOOKEEPER
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $ZOOKEEPER
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$KAFKA-headless
  namespace: $NAMESPACE
  labels:
    app.kubernetes.io/name: $KAFKA
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $KAFKA
spec:
  type: ClusterIP
  clusterIP: None
  ports:
    - name: tcp-client
      port: 9092
      protocol: TCP
      targetPort: kafka-client
    - name: tcp-internal
      port: 9093
      protocol: TCP
      targetPort: kafka-internal
  selector:
    app.kubernetes.io/name: $KAFKA
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $KAFKA
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$KAFKA
  namespace: $NAMESPACE
  labels:
    app.kubernetes.io/name: $KAFKA
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $KAFKA
spec:
  type: ClusterIP
  ports:
    - name: tcp-client
      port: 9092
      protocol: TCP
      targetPort: kafka-client
      nodePort: null
  selector:
    app.kubernetes.io/name: $KAFKA
    app.kubernetes.io/instance: $BITNAMI
    app.kubernetes.io/component: $KAFKA
---
apiVersion: v1
kind: Service
metadata:
  name: $KAFDROP
  namespace: $NAMESPACE
  labels:
    app: $KAFDROP
    release: $KAFDROP
spec:
  ports:
    - name: kafdrop-http
      port: 9000
  selector:
    app: $KAFDROP
    release: $KAFDROP
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$KAFKA_CONNECT
  namespace: $NAMESPACE
  labels:
    app: $KAFKA_CONNECT
    release: $BITNAMI
spec:
  ports:
    - name: kafka-connect
      port: 8083
  selector:
    app: $KAFKA_CONNECT
    release: $BITNAMI
---
apiVersion: v1
kind: Service
metadata:
  name: $BITNAMI-$SCHEMA_REGISTRY
  namespace: $NAMESPACE
  labels:
    app: $SCHEMA_REGISTRY
    release: $BITNAMI
spec:
  ports:
    - name: schema-registry
      port: 8081
  selector:
    app: $SCHEMA_REGISTRY
    release: $BITNAMI
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: $KAFDROP
  namespace: $NAMESPACE
  labels:
    app: $KAFDROP
    release: $KAFDROP
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $KAFDROP
      release: $KAFDROP
  template:
    metadata:
      labels:
        app: $KAFDROP
        release: $KAFDROP
    spec:
      serviceAccountName: $PREFIX-insight
      containers:
        - name: $KAFDROP
          image: $KAFDROP_IMAGE
          imagePullPolicy: IfNotPresent
          ports:
            - name: kafdrop-http
              containerPort: 9000
              protocol: TCP
          env:
            - name: KAFKA_BROKERCONNECT
              value: $BITNAMI-$KAFKA-headless:9092
            - name: SCHEMAREGISTRY_CONNECT
              value: http://$BITNAMI-$SCHEMA_REGISTRY:8081
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: $BITNAMI-$KAFKA_CONNECT
  namespace: $NAMESPACE
  labels:
    app: $KAFKA_CONNECT
    release: $BITNAMI
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $KAFKA_CONNECT
      release: $BITNAMI
  template:
    metadata:
      labels:
        app: $KAFKA_CONNECT
        release: $BITNAMI
    spec:
      serviceAccountName: $PREFIX-insight
      containers:
        - name: $KAFKA_CONNECT-server
          image: $KAFKA_CONNECT_IMAGE
          imagePullPolicy: "IfNotPresent"
          ports:
            - name: kafka-connect
              containerPort: 8083
              protocol: TCP
          env:
            - name: CONNECT_REST_ADVERTISED_HOST_NAME
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: CONNECT_BOOTSTRAP_SERVERS
              value: PLAINTEXT://$BITNAMI-$KAFKA-headless:9092
            - name: CONNECT_GROUP_ID
              value: $BITNAMI
            - name: CONNECT_CONFIG_STORAGE_TOPIC
              value: $BITNAMI-$KAFKA_CONNECT-config
            - name: CONNECT_OFFSET_STORAGE_TOPIC
              value: $BITNAMI-$KAFKA_CONNECT-offset
            - name: CONNECT_STATUS_STORAGE_TOPIC
              value: $BITNAMI-$KAFKA_CONNECT-status
            - name: CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL
              value: http://$BITNAMI-$SCHEMA_REGISTRY:8081
            - name: CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL
              value: http://$BITNAMI-$SCHEMA_REGISTRY:8081
            - name: KAFKA_HEAP_OPTS
              value: "-Xms512M -Xmx512M"
            - name: "CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR"
              value: "1"
            - name: "CONNECT_INTERNAL_KEY_CONVERTER"
              value: "org.apache.kafka.connect.json.JsonConverter"
            - name: "CONNECT_INTERNAL_VALUE_CONVERTER"
              value: "org.apache.kafka.connect.json.JsonConverter"
            - name: "CONNECT_KEY_CONVERTER"
              value: "io.confluent.connect.avro.AvroConverter"
            - name: "CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE"
              value: "false"
            - name: "CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR"
              value: "1"
            - name: "CONNECT_PLUGIN_PATH"
              value: "/usr/share/java,/usr/share/confluent-hub-components"
            - name: "CONNECT_STATUS_STORAGE_REPLICATION_FACTOR"
              value: "1"
            - name: "CONNECT_VALUE_CONVERTER"
              value: "io.confluent.connect.avro.AvroConverter"
            - name: "CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE"
              value: "false"
            - name: "CONNECT_MAX_REQUEST_SIZE"
              value: "41943040"
            - name: "CONNECT_PRODUCER_MAX_REQUEST_SIZE"
              value: "41943040"
          resources: 
            requests:
              memory: "$REQUEST_KAFKA_CONNECT_MEMORY"
              cpu: "$REQUEST_KAFKA_CONNECT_CPU"
              ephemeral-storage: "$KAFKA_EPHERMERAL_STORAGE"      
            limits:
              memory: "$LIMIT_KAFKA_CONNECT_MEMORY"
              cpu: "$LIMIT_KAFKA_CONNECT_CPU"
              ephemeral-storage: "$KAFKA_EPHERMERAL_STORAGE"
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: $BITNAMI-$SCHEMA_REGISTRY
  namespace: $NAMESPACE
  labels:
    app: $SCHEMA_REGISTRY
    release: $BITNAMI
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $SCHEMA_REGISTRY
      release: $BITNAMI
  template:
    metadata:
      labels:
        app: $SCHEMA_REGISTRY
        release: $BITNAMI
    spec:
      serviceAccountName: $PREFIX-insight
      containers:
        - name: $SCHEMA_REGISTRY-server
          image: $SCHEMA_REGISTRY_IMAGE
          imagePullPolicy: "IfNotPresent"
          ports:
            - name: schema-registry
              containerPort: 8081
              protocol: TCP
          env:
          - name: SCHEMA_REGISTRY_HOST_NAME
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: SCHEMA_REGISTRY_LISTENERS
            value: http://0.0.0.0:8081
          - name: SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS
            value: PLAINTEXT://$BITNAMI-$KAFKA-headless:9092
          - name: SCHEMA_REGISTRY_KAFKASTORE_GROUP_ID
            value: $BITNAMI
          - name: SCHEMA_REGISTRY_MASTER_ELIGIBILITY
            value: "true"
          - name: SCHEMA_REGISTRY_HEAP_OPTS
            value: "-Xms512M -Xmx512M"
          - name: SCHEMA_REGISTRY_AVRO_COMPATIBILITY_LEVEL
            value: "none"
          resources: 
            requests:
              memory: "$REQUEST_SCHEMA_REGISTRY_MEMORY"
              cpu: "$REQUEST_SCHEMA_REGISTRY_CPU"
              ephemeral-storage: "$KAFKA_EPHERMERAL_STORAGE"        
            limits:
              memory: "$LIMIT_SCHEMA_REGISTRY_MEMORY"
              cpu: "$LIMIT_SCHEMA_REGISTRY_CPU"
              ephemeral-storage: "$KAFKA_EPHERMERAL_STORAGE"
EOF

sed "s#{BITNAMI}#$BITNAMI#g" kafka-statefulset.yaml > kafka-statefulset-deploy-tmp0.yaml
sed "s#{ZOOKEEPER}#$ZOOKEEPER#g" kafka-statefulset-deploy-tmp0.yaml >kafka-statefulset-deploy-tmp1.yaml
sed "s#{KAFKA}#$KAFKA#g" kafka-statefulset-deploy-tmp1.yaml > kafka-statefulset-deploy-tmp2.yaml
sed "s#{KAFKA_BROKER_IMAGE}#$KAFKA_BROKER_IMAGE#g" kafka-statefulset-deploy-tmp2.yaml > kafka-statefulset-deploy-tmp3.yaml
sed "s#{ZOOKEEPER_IMAGE}#$ZOOKEEPER_IMAGE#g" kafka-statefulset-deploy-tmp3.yaml > kafka-statefulset-deploy-tmp4.yaml
sed "s#{PREFIX}#$PREFIX#g" kafka-statefulset-deploy-tmp4.yaml > kafka-statefulset-deploy-tmp5.yaml
sed "s#{REQUEST_ZOOKEEPER_CPU}#$REQUEST_ZOOKEEPER_CPU#g" kafka-statefulset-deploy-tmp5.yaml > kafka-statefulset-deploy-tmp6.yaml
sed "s#{REQUEST_ZOOKEEPER_MEMORY}#$REQUEST_ZOOKEEPER_MEMORY#g" kafka-statefulset-deploy-tmp6.yaml > kafka-statefulset-deploy-tmp7.yaml
sed "s#{REQUEST_ZOOKEEPER_STORAGE}#$REQUEST_ZOOKEEPER_STORAGE#g" kafka-statefulset-deploy-tmp7.yaml > kafka-statefulset-deploy-tmp8.yaml
sed "s#{LIMIT_ZOOKEEPER_CPU}#$LIMIT_ZOOKEEPER_CPU#g" kafka-statefulset-deploy-tmp8.yaml > kafka-statefulset-deploy-tmp9.yaml
sed "s#{LIMIT_ZOOKEEPER_MEMORY}#$LIMIT_ZOOKEEPER_MEMORY#g" kafka-statefulset-deploy-tmp9.yaml > kafka-statefulset-deploy-tmp10.yaml
sed "s#{LIMIT_ZOOKEEPER_STORAGE}#$LIMIT_ZOOKEEPER_STORAGE#g" kafka-statefulset-deploy-tmp10.yaml > kafka-statefulset-deploy-tmp11.yaml
sed "s#{ZOOKEEPER_EPHERMERAL_STORAGE}#$ZOOKEEPER_EPHERMERAL_STORAGE#g" kafka-statefulset-deploy-tmp11.yaml > kafka-statefulset-deploy-tmp12.yaml
sed "s#{KAFKA_EPHERMERAL_STORAGE}#$KAFKA_EPHERMERAL_STORAGE#g" kafka-statefulset-deploy-tmp12.yaml > kafka-statefulset-deploy-tmp13.yaml
sed "s#{REQUEST_KAFKA_CPU}#$REQUEST_KAFKA_CPU#g" kafka-statefulset-deploy-tmp13.yaml > kafka-statefulset-deploy-tmp14.yaml
sed "s#{REQUEST_KAFKA_MEMORY}#$REQUEST_KAFKA_MEMORY#g" kafka-statefulset-deploy-tmp14.yaml > kafka-statefulset-deploy-tmp15.yaml
sed "s#{REQUEST_KAFKA_STORAGE}#$REQUEST_KAFKA_STORAGE#g" kafka-statefulset-deploy-tmp15.yaml > kafka-statefulset-deploy-tmp16.yaml
sed "s#{LIMIT_KAFKA_CPU}#$LIMIT_KAFKA_CPU#g" kafka-statefulset-deploy-tmp16.yaml > kafka-statefulset-deploy-tmp17.yaml
sed "s#{LIMIT_KAFKA_MEMORY}#$LIMIT_KAFKA_MEMORY#g" kafka-statefulset-deploy-tmp17.yaml > kafka-statefulset-deploy-tmp18.yaml
sed "s#{LIMIT_KAFKA_STORAGE}#$LIMIT_KAFKA_STORAGE#g" kafka-statefulset-deploy-tmp18.yaml > kafka-statefulset-deploy-tmp19.yaml
sed "s#{NAMESPACE}#$NAMESPACE#g" kafka-statefulset-deploy-tmp19.yaml > kafka-statefulset-deploy-tmp20.yaml
sed "s#{STORAGE_CLASS}#$STORAGE_CLASS#g" kafka-statefulset-deploy-tmp20.yaml > kafka-statefulset-deploy.yaml

kubectl apply -f kafka-statefulset-deploy.yaml -n $NAMESPACE

rm kafka-statefulset-deploy*