# mykrobe-atlas-api-k8

Followed base setup from cert-manager.io.

Issuer is custom and requires a secret

__

Get API key for the domain from cloudflare

Get a base64 encoded version using
echo -n '<APIKEY>' | openssl base64

Use that to create an api key secret

__


Update the ingress

