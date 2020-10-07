#!/bin/sh

vault policy write mongo /home/vault/mongo-policy.hcl 

vault write auth/kubernetes/role/mongo \
   bound_service_account_names=atlas-api-sa \
   bound_service_account_namespaces=mykrobe \
   policies=mongo \
   ttl=24h

vault write database/config/mongo \
    plugin_name=mongodb-database-plugin \
    allowed_roles="mongo" \
    connection_url="mongodb://{{username}}:{{password}}@mykrobe-mongodb-replicaset-client.mykrobe.svc:27017/admin?replicaSet=rs0" \
    username="admin" \
    password=<password>

vault write database/roles/mongo \
    db_name=mongo \
    creation_statements='{ "db": "atlas", "roles": [{ "role": "readWrite" }] }' \
    default_ttl="1h" \
    max_ttl="24h"

vault read database/creds/mongo