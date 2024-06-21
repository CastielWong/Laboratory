
- [Concept](#concept)
- [Common Command](#common-command)
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

# release
helm list --all
helm status {release}
helm history {release}
helm get values {release}

helm upgrade -f {config}.yaml {release} {chart}
helm rollback {RELEASE} {REVISION}

# uninstall a release
helm uninstall {release}
```


## Reference
- Quick Start: https://helm.sh/docs/intro/quickstart/
