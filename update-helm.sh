#!/usr/bin/env bash


(cd helm ; helm package azure-snapshoter)

helm repo index helm --url https://dbarthe.github.io/azure-snapshoter.sh/helm