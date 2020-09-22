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

### GCR

In directory `/static-embassy/gcr`, run in the configuration `./config.sh`

to create gcr credentials `insight` and `mykrobe`

### VAULT

In directory `/static-embassy/vault`, run in the configuration `./config.sh`

to create the vault and sidecar-injector agent

To initialise the vault operator ssh to the vault-0 pod and run the following command `vault operator init` and take note of the keys

To unseal the vault operator ssh to the vault-0 pod and run the following command `vault operator unseal` for all the unseal keys provided in the previous step

To enable kubernetes authentication, run the following command: `vault auth enable kubernetes || true`

Run this command to create the kubernetes config (replace CLUSTER_URL by your cluster url):

`vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host=CLUSTER_URL \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`

Run this to enable database secrets `vault secrets enable database || true`