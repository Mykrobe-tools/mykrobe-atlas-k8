path "secret/*" {
  capabilities = ["read","create","update","delete"]
}

path "secret/metadata/*" {
   capabilities = ["list"]
}

path "database/*" {
  capabilities = ["read","create","update","delete"]
}

path "database/metadata/*" {
   capabilities = ["list"]
}