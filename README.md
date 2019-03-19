azure-snapshoter.sh
===================

**azure-snapshoter.sh** is a simple bash CLI that helps to create backup of azure disks.

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

## Run inside Kubernetes

**azure-snapshoter.sh** runs fine as a [kubernetes cronjob](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/).

The helm package helps doing this, checkout the `examples/values.yaml` first, then try :
```bash
helm repo add azure-snapshoter https://dbarthe.github.io/azure-snapshoter.sh/helm
helm install azure-snapshoter/azure-snapshoter -f examples/values.yaml \
  --set-string sp_id=$SP_ID,sp_password=$SP_PASSWORD,tenant_id=$TENANT_ID
```

It creates a secret for the azure credentials.

## TODO

- manage snapshot retention
