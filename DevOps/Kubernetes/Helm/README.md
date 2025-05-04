
- [Concept](#concept)
- [Common Command](#common-command)
- [Template](#template)
- [Reference](#reference)

Helm helps to manage Kubernetes applications — Helm Charts help to define, install, and
upgrade even the most complex Kubernetes application.

Charts are easy to create, version, share, and publish — so start using Helm and stop
the copy-and-paste.

## Concept
A __Repository__ is the place where charts can be collected and shared.
It's like Perl's CPAN archive or the Fedora Package Database, but for K8S packages.

A __Chart__ is a Helm package.
It contains all of the resource definitions necessary to run an application, tool, or
service inside of a Kubernetes cluster.
Think of it like the K8S equivalent of a Homebrew formula, an Apt dpkg, or a Yum RPM file.

A __Release__ is an instance of a chart running in a Kubernetes cluster.
One chart can often be installed many times into the same cluster.
And each time it is installed, a new release is created.


## Common Command
Note that Helm would follow the same context as Kubernetes:
```sh
# repo
helm repo list
helm search hub {chart}
helm repo add {name} {repo}
helm repo update
helm repo remove {name}

helm search repo {chart}


# chart
helm show values {chart}

# install a release for a chart
helm install {name} {chart}
helm install -f {config}.yaml {chart} --generate-name

# create chart
helm create {chart}
helm package {chart}

# note that it must be "Chart.yaml", and files inside "templates/"
helm template {release} -f {values}.yaml --dry-run=client .


# release
helm list --all -n {namespace}
helm status {release}
helm history {release}
helm get values {release}

helm upgrade {release} {chart} -f {config}.yaml
# roll back to previous release
helm rollback {release} {revision}

# uninstall a release
helm uninstall {release}
```


## Template
Helm provides templates for built-in objects, one of which is the __Values__.
__Values__ provides access to values passed into the chart.

Its contents come from multiple sources:
- the "values.yaml" file in the chart
- if this is a subchart, the "values.yaml" file of a parent chart
- a values file if passed into `helm install` or `helm upgrade` with the `-f` flag,
like `helm install -f {value}.yaml ./{chart}`
- individual parameters passed with `--set`,
like `helm install --set {key}={value} ./{chart}`

The list above is in order of specificity: "values.yaml" is the default, which can be
overridden by a parent chart's "values.yaml", which can in turn be overridden by a
user-supplied values file, which can in turn be overridden by `--set` parameters.

For instance:
- values.yaml
    ```yaml
    a_key: a_value
    ```
- config_map.yaml:
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
        name: {{ .Release.Name }}-configmap
    data:
        demo: "Hello World"
        key_value: {{ .Values.a_key }}
    ```


## Reference
- Quick Start: https://helm.sh/docs/intro/quickstart/
