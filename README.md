# Atlas Kubernetes Specifications

Kubernetes specifications to deploy Atlas services. These are deployed to Embassy Hosted Kubernetes (EHK).

## Services

### Mykrobe (mykrobe-dev, mykrobe-uat, mykrobe)

- Atlas Client - Atlas web and desktop front-end
- Atlas API - Atlas backend API
- MongoDB - Atlas datastore
- Analysis API - Analysis API for resistance prediction
- BIGSI API - Atlas to access BItsliced Genomic Signature Index (BIGSI) for distance calculations
- Keycloak - User Account management

### Insight (insight-dev, insight-uat, insight)

- Confluent - Kafka pipelines
- Kafka Consumer - Consumer for Atlas
- Metabase - Ad-hoc reporting
- MySQL - Reporting database

### Search (search)

- Elasticsearch - elasticsearch cluster

### Shared (shared)

- Vault - Hashcorp vault to manage secrets

### Cert Manager (cert-manager)

- Cert Manager - TLS certificate management

## Installation

### Namespaces

In directory `/static-embassy/namespaces`, run in the configuration `./config.sh`

to create namespaces `insight`, `mykrobe` and `shared`

Verify using

```
kubectl get namespaces
```

and see

```
NAME              STATUS   AGE
insight           Active   4h27m
mykrobe           Active   4h27m
shared            Active   4h27m
```

### GCR

In directory `/static-embassy/gcr`, run in the configuration `./config.sh`

to create gcr credentials `insight` and `mykrobe`

Verify using

```
kubectl get secrets -n insight
kubectl get secrets -n mykrobe
```

and see

```
NAME                  TYPE                                  DATA   AGE
gcr-json-key          kubernetes.io/dockerconfigjson        1      4h28m
```

### MongoDB
In directory `/static-embassy/mongo-replica-set`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the username, passwords and key then run it in.

This will create a mongo db cluster with 3 replicas

Verify using

```
kubectl get pods -n mykrobe
```

and see

```
NAME                           READY   STATUS    RESTARTS   AGE
mykrobe-mongodb-replicaset-0   1/1     Running   0          164m
mykrobe-mongodb-replicaset-1   1/1     Running   0          163m
mykrobe-mongodb-replicaset-2   1/1     Running   0          163m
```

### Cert Manager
In directory `/static-embassy/certmanager`, copy config.sample.sh and replace the CLOUDFLARE_API_KEY by your cloudflare key in the copied file and run it in.

this will deploy all the certmanager components

Verify using

```
kubectl get all -n cert-manager
```

and see

```
NAME                                           READY   STATUS    RESTARTS   AGE
pod/cert-manager-75856bb467-szm5t              1/1     Running   0          2m23s
pod/cert-manager-cainjector-597f5b4768-xd4k4   1/1     Running   0          2m23s
pod/cert-manager-webhook-5c9f7b5f75-7b6cc      1/1     Running   0          2m23s

NAME                           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/cert-manager           ClusterIP   10.43.146.63   <none>        9402/TCP   2m23s
service/cert-manager-webhook   ClusterIP   10.43.103.19   <none>        443/TCP    2m23s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           2m23s
deployment.apps/cert-manager-cainjector   1/1     1            1           2m23s
deployment.apps/cert-manager-webhook      1/1     1            1           2m23s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cert-manager-75856bb467              1         1         1       2m23s
replicaset.apps/cert-manager-cainjector-597f5b4768   1         1         1       2m23s
replicaset.apps/cert-manager-webhook-5c9f7b5f75      1         1         1       2m23s
```

### Keycloak

In directory `/static-embassy/keycloak`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords then run it in.

This will create a postgres and keycloak

Verify using

```
kubectl get pods -n mykrobe
```

and see

```
NAME                                   READY   STATUS    RESTARTS   AGE
keycloak-deployment-75f857d8c5-z7lct   1/1     Running   0          8m48s
postgres-596bcb6dc8-6fxhs              1/1     Running   0          8m49s
```

Access the front-end at e.g. https://accounts-uat.mykro.be

Verify keycloak realm for Atlas allows the correct origin environment - dev.mykro.be, uat.mykro.be, www.mykro.be, mykro.be

Verify the SMTP settings in the email tab

### Vault

In directory `/static-embassy/vault`, run in the configuration `./config.sh`

to create the vault and sidecar-injector agent

Verify using

```
kubectl get pods -n shared
```

and see

```
NAME                                   READY   STATUS    RESTARTS   AGE
vault-0                                1/1     Running   0          4h17m
vault-agent-injector-c49c94bf4-xvncn   1/1     Running   0          4h12m
```

To initialise the vault operator ssh to the vault-0 pod and run the following command `vault operator init` and take note of the keys

To unseal the vault operator ssh to the vault-0 pod and run the following command `vault operator unseal` for all the unseal keys provided in the previous step

To enable kubernetes authentication, run the following command: `vault auth enable kubernetes || true`

Run this command to create the kubernetes config (replace CLUSTER_URL by your cluster url):

```
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host=CLUSTER_URL \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
```

Run this to enable database secrets `vault secrets enable database || true`

#### Setup MongoDb Policy

In directory `/static-embassy/vault`, ssh to the vault pod and run the commands in configure-mongo.sh

#### Setup Key/Value Policy

In directory `/static-embassy/vault`, ssh to the vault pod and run the commands in configure-kv.sh

Run this inside the vault pod to enable kv secrets `vault secrets enable kv || true`

Port-forward the vault pod: `kubectl port-forward vault-0 8200:8200 -n shared`

Copy the create-secrets.sh and replace the keys then run the script to create the secrets in vault: `./create-secrets.sh`

### Elasticsearch

In directory `/static-embassy/elasticsearch`, create a new config file with your setting by copying the sample file for your target environment and run it.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords then run it in using e.g. `./config-dev.sh`.  This will create a deployment for the Elasticsearch cluster

Verify using

```
kubectl get pods -n search
```

and see

```
NAME                      READY   STATUS    RESTARTS   AGE
mykrobe-elasticsearch-0   1/1     Running   0          102s
mykrobe-elasticsearch-1   1/1     Running   0          101s
```

### API

In directory `/static-embassy/atlas-api`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords and keys then run it in using e.g. `./config-dev.sh`.  This will create a deployment for the API

Verify using

```
kubectl get pods -n mykrobe
```

and see

```
NAME                                    READY   STATUS    RESTARTS   AGE
atlas-api-deployment-745f865577-5f57g   2/2     Running   0          3m5s
```

Access the front-end at e.g. https://api-uat.mykro.be/health-check

### Client

In directory `/static-embassy/atlas-client`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords and keys then run it in using e.g. `./config-dev.sh`.  This will create a deployment for the atlas client

Verify using

```
kubectl get pods -n mykrobe
```

and see

```
NAME                                    READY   STATUS    RESTARTS   AGE
atlas-deployment-6df765696-p86rn        2/2     Running   0          15m
```

Access the front-end at e.g. https://uat.mykro.be

### Analysis API

In directory `/static-embassy/analysis-api`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords and keys then run it in using e.g. `./config-dev.sh`.  This will create a deployment for the analysis api and worker, the bigsi api and worker, redis and the tracking api

Verify using

```
kubectl get pods -n mykrobe
```

and see

```
NAME                                               READY   STATUS    RESTARTS   AGE
analysis-api-f685f75df-f6hhg                       1/1     Running   0          4m36s
analysis-api-worker-546849f658-jljvd               1/1     Running   0          4m36s
bigsi-api-aggregator-deployment-5fd495bb76-qfxx6   1/1     Running   0          112s
bigsi-api-aggregator-worker-8478d64dcf-nmdxq       1/1     Running   0          112s
bigsi-api-deployment-big-6f648fc64d-kbcvn          1/1     Running   0          111s
bigsi-api-deployment-small-8465bbdb77-d64ht        1/1     Running   0          111s
distance-api-deployment-65b6f9f7f5-46hsm           1/1     Running   0          108s
neo4j-deployment-6d67694dbc-6qx4r                  1/1     Running   0          41m
redis-0                                            1/1     Running   0          44m
tracking-api-deployment-798f96d4c5-6fb6v           1/1     Running   0          105s
tracking-db-deployment-97f979485-wlz9t             1/1     Running   0          107s
```

### Surveillance

#### Confluent OSS

In directory `/static-embassy/confluent-oss`, run the file for your target environment

For example:

* Development: run config-dev.sh
* UAT: run config-uat.sh
* Production: run config-prod.sh

This will create a deployemt for the confluent oss in the insight namespace

Verify using

```
kubectl get pods -n insight
```

and see

```
NAME                                                 READY   STATUS    RESTARTS   AGE
mykrobe-confluent-cc-556c84b5d8-242fw                1/1     Running   3          2m14s
mykrobe-confluent-kafka-0                            1/1     Running   0          96s
mykrobe-confluent-kafka-1                            1/1     Running   0          67s
mykrobe-confluent-kafka-2                            1/1     Running   0          39s
mykrobe-confluent-kafka-connect-5dd44b4dd9-f7rjr     1/1     Running   0          97s
mykrobe-confluent-schema-registry-54ff74dd94-q969r   1/1     Running   0          97s
mykrobe-confluent-zookeeper-0                        1/1     Running   0          95s
mykrobe-confluent-zookeeper-1                        1/1     Running   0          71s
mykrobe-confluent-zookeeper-2                        1/1     Running   0          47s
```

Port forward the controle-centre service using `kubectl port-forward svc/mykrobe-confluent-cc 9021:9021 -n insight`
Access the front-end at: http://localhost:9021 and make sure the cluster is in healthy state

#### Mysql

In directory `/static-embassy/metabase/mysql`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords and keys then run it in using e.g. `./config-dev.sh`.  This will create a deployment for the mysql database

Verify using

```
kubectl get pods -n insight
```

and see

```
NAME                                                 READY   STATUS    RESTARTS   AGE
mykrobe-mysql-74d6598dd4-rw2db                       1/1     Running   0          13m
```

#### Metabase

Create a database called metabase in mysql `CREATE DATABASE metabase;` 

Grant privileges to mykrobe user `GRANT ALL PRIVILEGES ON metabase.* TO 'mykrobe'@'%';`

In directory `/static-embassy/metabase`, create a new config file with your setting by copying the sample file for your target environment.

For example:

* Development: copy config-dev.sample.sh
* UAT: copy config-uat.sample.sh
* Production: copy config-prod.sample.sh

Replace the passwords and keys then run it in using e.g. `./config-dev.sh`.  This will create a deployment for metabase

Verify using

```
kubectl get pods -n insight
```

and see

```
NAME                                                 READY   STATUS    RESTARTS   AGE
mykrobe-insight-84c677f867-jxr44                     1/1     Running   0          77m
```

#### Create Kafka Connectors

In directory `/static-embassy/confluent-oss`, create a new file with your setting by copying the sample file for your target environment.

For example:

* Development: copy create-connectors-dev.sh
* UAT: copy create-connectors-uat.sh
* Production: copy create-connectors-prod.sh

Port forward the kafka-connect service using `kubectl port-forward svc/mykrobe-confluent-kafka-connect 8083:8083 -n insight`

Replace the passwords in the copied script then run it in using e.g. `./create-connectors-dev-with-passwords.sh`.  This will the sink and source connectors 

Verify:

Port forward the controle-centre service using `kubectl port-forward svc/mykrobe-confluent-cc 9021:9021 -n insight`

Then visit `http://localhost:9021/` and go to cluster->connect you should see 6 connectors running

#### Kafka Consumer

In directory `/static-embassy/metabase/kafka-consumer`, run the config file for your target environment/

For example:

* Development: run config-dev.sh
* UAT: run config-uat.sh
* Production: run config-prod.sh

Verify using

```
kubectl get pods -n insight
```

and see

```
NAME                                                 READY   STATUS    RESTARTS   AGE
mykrobe-kafka-consumer-79d84ff847-g6cdv              1/1     Running   0          41m
```