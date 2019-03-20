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

Optionally define how long you want to keep the snapshots (in plain english):
```bash
export RETENTION="1 month"

# or 
export RETENTION="3 days"

# or anything that fit in `date -d "-$RETENTION"`
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
  -e RETENTION="10 days" \
   barthelemy/azure-snapshoter
```

## Run inside Kubernetes

**azure-snapshoter.sh** runs fine as a [kubernetes cronjob](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/).

There is an Helm chart to make it easy, start by adding this repo :
```bash
helm repo add azure-snapshoter https://dbarthe.github.io/azure-snapshoter.sh/helm
```

Create a file `values.yaml`:
```yaml
schedule: "* * * * *"
retention: "10 days"

# required values
resource_group: snapshots
location: westeurope
snapshot_base_name: nexus

# optional (either disk_id or disk_tag is required)
disk_id:
disk_tag: kubernetes.io-created-for-pvc-name=nexus-sonatype-nexus-data

# azure credentials stored as k8s secret - can be set from the command line
#sp_id:
#sp_password:
#tenant_id:
```

Then install it (requires Tiller to be deployed):
```
helm install azure-snapshoter/azure-snapshoter -f values.yaml \
  --set-string sp_id=$SP_ID,sp_password=$SP_PASSWORD,tenant_id=$TENANT_ID
```

Checkout [helm/azure-snapshoter/values.yaml]() for more options.
