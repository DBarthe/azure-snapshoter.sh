#!/usr/bin/env bash

set -xe

main() {
  # where to store the snapshots
  # tag to track (optional if disk id is set)
  require RESOURCE_GROUP
  require LOCATION

  # base name of the snapshot
  require SNAPSHOT_BASE_NAME

  # how long time to keep the snapshots in plain english ("1 month", "2 days", "5 hours", ...)
  # optional RETENTION

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

  if [ "$RETENTION" != "" ]; then
    delete_old_snapshots
  else
    echo "No RETENTION set. Did not delete anything"
  fi
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

get_old_snapshots() {
  local delete_before=$(date -d "-$RETENTION")
  local delete_before_ts=$(date +%s -d "-$RETENTION")

  echo "Looking for snapshots to delete before $delete_before" >&2;

  az snapshot list -g $RESOURCE_GROUP |
    jq -r '.[] | select(.name|startswith("'$SNAPSHOT_BASE_NAME'-")) |
      select(.timeCreated | sub("\\.[0-9]+\\+.*$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime < '$delete_before_ts')|.id'
}

delete_old_snapshots() {

  for id in $(get_old_snapshots); do
     echo "deleting snapshot $id ..."
     az snapshot delete --ids "$id"
  done
}

main $@