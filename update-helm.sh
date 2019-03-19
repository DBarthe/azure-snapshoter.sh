#!/usr/bin/env bash


(cd helm ; helm package azure-snapshoter)

helm repo index helm --url https://github.com/DBarthe/azure-snapshoter.sh/tree/master/helm