#!/usr/bin/env bash

if [ "$SP_ID" != "" ]; then
  az login --service-principal -u $SP_ID -p $SP_PASSWORD --tenant $TENANT_ID
fi

exec $@