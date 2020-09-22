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

Access the front-end at: https://accounts-uat.mykro.be

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

