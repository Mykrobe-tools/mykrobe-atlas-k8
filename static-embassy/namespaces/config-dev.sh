#!/bin/bash

echo "Namespaces: "
echo " - mykrobe-dev"
echo " - insight-dev"
echo " - shared"
echo " - search"
echo ""

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: mykrobe-dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: insight-dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: shared
---
apiVersion: v1
kind: Namespace
metadata:
  name: search
EOF
