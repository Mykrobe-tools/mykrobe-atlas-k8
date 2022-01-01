#!/bin/bash

export HIGH_PRIORITY_CLASS_NAME="high-priority"
export HIGH_PRIORITY_CLASS_DESC="This priority class should be used for critical service pods that cannot be down at all cost (databases, caches, message queues, etc.) only."
export HIGH_PRIORITY_CLASS_VALUE=1000000

export HIGH_PRIORITY_NON_PREEMP_CLASS_NAME="high-priority-nonpreempting"
export HIGH_PRIORITY_NON_PREEMP_CLASS_DESC="This priority class will not be killed by lower-priority pods but will not kill those either."
export HIGH_PRIORITY_NON_PREEMP_CLASS_VALUE=1000000

# Mostly exists for clarity only. See the docs for the `globalDefault` property for more info.
export NORMAL_PRIORITY_CLASS_NAME="normal-priority"
export NORMAL_PRIORITY_CLASS_DESC="The default priority."
export NORMAL_PRIORITY_CLASS_VALUE=0

echo "Priority classes:"
echo " - $HIGH_PRIORITY_CLASS_NAME: $HIGH_PRIORITY_CLASS_VALUE - $HIGH_PRIORITY_CLASS_DESC"
echo " - $HIGH_PRIORITY_NON_PREEMP_CLASS_NAME: $HIGH_PRIORITY_NON_PREEMP_CLASS_VALUE - $HIGH_PRIORITY_NON_PREEMP_CLASS_DESC"
echo " - $NORMAL_PRIORITY_CLASS_NAME: $NORMAL_PRIORITY_CLASS_VALUE - $NORMAL_PRIORITY_CLASS_DESC"

cat <<EOF | kubectl apply -f -
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: $HIGH_PRIORITY_CLASS_NAME
value: $HIGH_PRIORITY_CLASS_VALUE
globalDefault: false
description: $HIGH_PRIORITY_CLASS_DESC
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: $HIGH_PRIORITY_NON_PREEMP_CLASS_NAME
value: $HIGH_PRIORITY_NON_PREEMP_CLASS_VALUE
preemptionPolicy: Never
globalDefault: false
description: $HIGH_PRIORITY_NON_PREEMP_CLASS_DESC
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: $NORMAL_PRIORITY_CLASS_NAME
value: $NORMAL_PRIORITY_CLASS_VALUE
globalDefault: true
description: $NORMAL_PRIORITY_CLASS_DESC
EOF
