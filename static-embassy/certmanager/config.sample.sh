#!/bin/bash

export NAMESPACE="cert-manager"
export NAME="cert-manager"
export VERSION="v0.15.1"
export CLOUDFLARE_API_KEY=`echo -n "<CLOUDFLARE_API_KEY>" | base64`
export CLOUDFLARE_ACCOUNT_EMAIL="cloudflare@makeandship.com"
export CLOUDFLARE_NOTIFICATION_EMAIL="mark@makeandship.com"

sh ./deploy.sh