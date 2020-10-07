#!/bin/sh

vault policy write kv /home/vault/kv-policy.hcl 

vault write auth/kubernetes/role/atlas \
   bound_service_account_names=atlas-sa \
   bound_service_account_namespaces=mykrobe \
   policies=kv \
   ttl=24h