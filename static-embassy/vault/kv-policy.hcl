path "secret/*" {
  capabilities = ["read","create","update","delete"]
}

path "secret/metadata/*" {
   capabilities = ["list"]
}

path "kv/*" {
  capabilities = ["read","create","update","delete"]
}

path "kv/metadata/*" {
   capabilities = ["list"]
}