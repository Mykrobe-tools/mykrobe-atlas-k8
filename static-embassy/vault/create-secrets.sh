#!/bin/bash

export VAULT_TOKEN=<VAULT_TOKEN>
export ES_PASSWORD=<ES_PASSWORD>
export KEYCLOAK_ADMIN_PASSWORD=<KEYCLOAK_ADMIN_PASSWORD>
export AWS_ACCESS_KEY=<AWS_ACCESS_KEY>
export AWS_SECRET_KEY=<AWS_SECRET_KEY>

curl -X POST \
  http://localhost:8200/v1/kv/atlas-dev \
  -H 'Content-Type: application/json' \
  -H 'X-Vault-Token: '"$VAULT_TOKEN"'' \
  -d '{
  "ES_PASSWORD": "'"$ES_PASSWORD"'"",
  "KEYCLOAK_ADMIN_PASSWORD": "'"$KEYCLOAK_ADMIN_PASSWORD"'"",
  "AWS_ACCESS_KEY": "'"$AWS_ACCESS_KEY"'"",
  "AWS_SECRET_KEY": "'"$AWS_SECRET_KEY"'""
}'