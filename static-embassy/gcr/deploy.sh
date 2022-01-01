#!/bin/bash

echo "GCR credentials: "
echo " - mykrobe"
echo " - insight"
echo ""

kubectl create secret docker-registry gcr-json-key \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$(cat ./gcr-key.json)" \
	--docker-email=mark@makeandship.com \
	--namespace=mykrobe-dev

kubectl create secret docker-registry gcr-json-key \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$(cat ./gcr-key.json)" \
	--docker-email=mark@makeandship.com \
	--namespace=insight-dev
