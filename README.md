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
