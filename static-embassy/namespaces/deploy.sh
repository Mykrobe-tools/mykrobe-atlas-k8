#!/bin/bash

echo "Namespaces: "
echo " - mykrobe"
echo " - insight"
echo " - shared"
echo ""

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: mykrobe
---
apiVersion: v1
kind: Namespace
metadata:
  name: insight
---
apiVersion: v1
kind: Namespace
metadata:
  name: shared
EOF
