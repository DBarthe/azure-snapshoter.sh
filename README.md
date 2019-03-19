azure-snapshoter.sh
===================

**azure-snapshoter.sh** is a simple bash CLI that help to create backup of azure disks.

## Usage

Define where to store the snapshot :
```bash
export RESOURCE_GROUP=[...]
export LOCATION=[...]
export SNAPSHOT_BASE_NAME=[...]
```

Define what disk to snapshot explicitly or using tags :
```bash
# either 
export DISK_ID=[managed_disk_id]

# or
export DISK_TAG="key=value"
```

Tag is useful is you want to snapshot a Kubernetes persistent volume for instance : `kubernetes.io-created-for-pvc-name=nexus-sonatype-data`.

Then, run the script :
```bash
./azure-snapshoter.sh
```

## Run with docker

```bash
docker run --rm -it \
  -e SP_ID=[azure sp id] \
  -e SP_PASSWORD=[azure sp password] \
  -e TENANT_ID=[azure tenant id] \
  -e RESOURCE_GROUP=[...] \
  -e LOCATION=[...] \
  -e SNAPSHOT_BASE_NAME=[...] \
  -e DISK_TAG=[...] \
   barthelemy/azure-snapshoter
```

## TODO

- manage snapshot retention
- kubernetes cron job manifest
