#!/bin/bash

export DEFAULT_STORAGE_CLASS="default-cinder"
export RWX_STORAGE_CLASS="rwx-storage"
export RWX_STORAGE_CAPACITY="100Gi"

sh ./deploy-storage-classes.sh