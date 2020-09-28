#!/bin/bash

COPY_FILES_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sleep 60 # wait 60 seconds for the container to be ready

podname="$(kubectl get pods --selector=app=$ANALYSIS_PREFIX -n $NAMESPACE -o jsonpath="{.items[0].metadata.name}")"

kubectl cp $COPY_FILES_SCRIPT_DIR/tb_tree.txt $NAMESPACE/$podname:/config/tb_tree.txt
kubectl cp $COPY_FILES_SCRIPT_DIR/NC_000962.3.fasta $NAMESPACE/$podname:/config/NC_000962.3.fasta
kubectl cp $COPY_FILES_SCRIPT_DIR/NC_000962.3.gb $NAMESPACE/$podname:/config/NC_000962.3.gb