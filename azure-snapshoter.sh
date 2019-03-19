#!/usr/bin/env bash

set -xe

main() {
  test_variables # for testing

  # where to store the snapshots
  # tag to track (optional if disk id is set)
  require RESOURCE_GROUP
  require LOCATION

  # base name of the snapshot
  require SNAPSHOT_BASE_NAME

  # either DISK_ID or DISK_TAG must be specified
  if [ "$DISK_TAG" = "" ] && [ "$DISK_ID" = "" ]; then
    echo "Either DISK_TAG or DISK_ID is required"
    exit 1
  fi
  DISK_ID=${DISK_ID:-$(get_disk_id "$DISK_TAG")}
  require DISK_ID

  # construct the snapshot name
  local name="$SNAPSHOT_BASE_NAME-$(date +%Y-%m-%d-%H-%M)"

  create_snapshot $name
}

require() {
  local name="$1"
  local val="${!name}"
  if [ "$val" = "" ]; then
    echo "error: $name is required"
    exit 1
  fi
}

create_snapshot() {

  local name="$1"
  az snapshot create --name "$name" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku "Standard_LRS" --source "$DISK_ID" ${DISK_TAG:+--tags $DISK_TAG}
}

get_disk_id() {
  local tag=$1

  local id_list=$(az resource list  --tag kubernetes.io-created-for-pvc-name=nexus-sonatype-nexus-data  | jq -r '.[] | select ( .type == "Microsoft.Compute/disks") | .id')
  local id_count=$(echo $id_list | wc -l)
  if [ "$id_count" -ne 1 ]; then
    echo "error: the tag '$tag' matched $id_count disk(s). It should have matched 1"
    exit 1
  fi
  echo $id_list
}

main $@