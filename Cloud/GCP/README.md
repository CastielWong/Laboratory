
Keep the most commonly used script to launch Google Cloud Platform services.

- [Google Cloud CLI](#google-cloud-cli)
  - [Configuration](#configuration)
  - [Project](#project)
  - [Deployment Manager](#deployment-manager)
  - [Compute Engine](#compute-engine)

Set up Infrastructure As Code for Google Cloud Platform.

## Google Cloud CLI
GCP provides CLI in its [SDK](https://cloud.google.com/sdk/docs/install-sdk) for the
ease of development.

Set an environment variable for the project via `export GCP_PROJECT={project_id}`,
which would be applied in Deployment Manager YAML as well.

Common commands:
```sh
# check SDK info
gcloud info
gcloud info --format='value(installation.sdk_root)'

# check credentials stored at local
gcloud auth list

gcloud init

gcloud components update
```

### Configuration
By default, GCP would keep its configurations under "~/.config/gcloud/configurations".

```sh
# list properties
gcloud config list
gcloud config configurations describe default

gcloud config configurations list
```

### Project
```sh
gcloud projects list

gcloud projects create {project_name}

gcloud projects describe $GCP_PROJECT

gcloud projects delete $GCP_PROJECT

gcloud config set project $GCP_PROJECT
gcloud config unset project
```

### Deployment Manager
```sh
gcloud deployment-manager deployments list

gcloud deployment-manager deployments create {deploy_name} --config {file}.yaml

gcloud deployment-manager deployments describe {deploy_name}

gcloud deployment-manager deployments delete {deploy_name}
```

### Compute Engine
Connect to the created instance: `gcloud compute ssh --zone "{zone}" "{instance}" --project "{project}"`
