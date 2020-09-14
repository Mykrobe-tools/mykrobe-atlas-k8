#!/bin/bash

echo "GCR credentials: "
echo " - mykrobe"
echo " - insight"
echo ""

kubectl create secret docker-registry gcr-json-key \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$(cat ./atlas-275810-1b85bf39eb34.json)" \
	--docker-email=mark@makeandship.com \
	--namespace=mykrobe 

kubectl create secret docker-registry gcr-json-key \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$(cat ./atlas-275810-1b85bf39eb34.json)" \
	--docker-email=mark@makeandship.com \
	--namespace=insight
