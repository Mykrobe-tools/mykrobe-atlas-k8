#!/bin/bash

cat <<EOF | kubectl apply -f -
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for critical service pods that cannot be down at all cost (databases, caches, message queues, etc.) only."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority-nonpreempting
value: 1000000
preemptionPolicy: Never
globalDefault: false
description: "This priority class will not be killed by lower-priority pods but will not kill those either."
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: normal-priority
value: 0
globalDefault: true
description: "The default priority. Mostly exists for clarity only. See the docs for the `globalDefault` property for more info."
EOF
