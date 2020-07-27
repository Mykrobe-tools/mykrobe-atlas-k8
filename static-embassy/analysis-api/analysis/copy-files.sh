#!/bin/bash

COPY_FILES_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

kubectl cp $COPY_FILES_SCRIPT_DIR/tb_tree.txt $2/$1:/config/tb_tree.txt
kubectl cp $COPY_FILES_SCRIPT_DIR/NC_000962.3.fasta $2/$1:/config/NC_000962.3.fasta
kubectl cp COPY_FILES_SCRIPT_DIR/NC_000962.3.gb $2/$1:/config/NC_000962.3.gb