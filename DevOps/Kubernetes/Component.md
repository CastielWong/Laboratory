
- [Skeleton](#skeleton)
- [Namespace](#namespace)
- [ReplicaSet](#replicaset)
- [Deployment](#deployment)
- [Service](#service)
  - [ClusterIP](#clusterip)
  - [NodePort](#nodeport)
  - [LoadBalancer](#loadbalancer)
  - [Headless](#headless)
  - [ExternalName](#externalname)
- [Pod](#pod)
  - [Multi-Container Pod](#multi-container-pod)
    - [Ambassador](#ambassador)
    - [Adapter](#adapter)
    - [Sidecar](#sidecar)
- [Label](#label)
- [Volume](#volume)
  - [Persistent Volume](#persistent-volume)
  - [Persistent Volume Claims](#persistent-volume-claims)
- [NetworkPolicy](#networkpolicy)
  - [Ingress](#ingress)

Kubernetes has a very rich __object model__(component), representing different
persistent entities in the Kubernetes cluster.

Those entities describe:
- what containerized applications running
- the nodes where the containerized applications are deployed
- application resource consumption
- policies attached to applications, like restart/upgrade policies, fault tolerance, etc

With each object, the intent or the desired state of the object, is declared in the `spec` section.
The Kubernetes system manages the `status` section for objects, where it
records the actual state of the object.
At any given point in time, the Kubernetes Control Plane tries to match the
object's actual state to the object's desired state.

When creating an object, the object's configuration data section from below the
`spec` field has to be submitted to the Kubernetes API server.
The API request to create an object must have the `spec` section, describing
the desired state, as well as other details.
Although the API server accepts object definition files in a JSON format, most
often it's suggested to provide such files in a YAML format, which is converted
by `kubectl` in a JSON payload and sent to the API server.

The default recommended controller is the Deployment which configures a
ReplicaSet controller to manage Pod's lifecycle.

__Layers of abstraction__:
- Deployment manages a ReplicateSet
- ReplicateSet manages a Pod
- Pod is an abstraction of Container

Object Models:
- Workload Management
  - Pod: the smallest deployable unit, hosting 1 or more containers
  - Node: represent a worker machine in the cluster that runs __Pods__
  - ReplicateSet: ensures a specified number of __Pods__ replicas are running
  - Deployment: (__Pods__ + __ReplicaSets__) manage the lifecycle of Pods, ensuring declarative updates and scaling
  - StatefulSet: manage stateful applications with stable network IDs and persistent storage
  - DaemonSet: ensure all nodes run a copy of a __Pod__
  - Job/CronJob: run short-lived or scheduled tasks to completion
- Network Discovery
  - Service: provide a stable IP/DNS name to load-balance traffic to __Pods__
  - Ingress: manage external HTTP/HTTPS access to __Services__
  - Endpoint: act as a bridge between a __Service__ and the __Pods__ that fulfill the service's request
  - EndpointSlice: track IP addresses of __Pods__ behind a __Service__ for efficient scaling
- Configuration & Storage
  - ConfigMap: store non-sensitive configuration as key-value pairs
  - Secret: similar to __ConfigMap__ but for sensitive data, stored encoded
  - Volume: provide ephemeral storage to __Pods__
  - PersistentVolume (PV): cluster-wide storage resource
  - PersistentVolumeClaim (PVC): __Pod__'s request for storage from a __PV__
- Cluster Management
  - Namespace: logical partitioning of cluster resources
  - Role/ClusterRole: define permission within a __Namespace__ or cluster-wide
  - RoleBinding/ClusterBinding: assign __Roles__ to users or __ServiceAccounts__
  - ServiceAccount: identify for __Pods__ to authenticate with K8S API
- Metadata & Scaling
  - HorizontalPodAutoscaler (HPA): automatically scale __Pods__ based on CPU/memory metrics
  - CustomResourceDefinition (CRD): extend K8S API with custom objects

Logical Hierarchy:
- Node -> Pod
- Deployment -> ReplicaSet -> Pods -> Containers
- Service -> Endpoint -> Pod
- Ingress -> Routes to Service -> Pods
- StatefulSet -> Pods + PersistentVolumeClaims



## Skeleton
```yaml
apiVersion: ...
kind: ...
metadata: ...
spec: ...
```

The `apiVersion` field is the first required field, and it specifies the API
endpoint on the API server which we want to connect to; it must match an
existing version for the object type defined.

The second required field is `kind`, specifying the object type - it can be
`Deployment`, `Pod`, `Replicaset`, `Namespace`, `Service`, etc.

The third required field `metadata`, holds the object's basic information,
such as `name`, `labels`, `namespace`, etc.

The fourth required field `spec` marks the beginning of the block defining
the desired state of the Deployment object.

Take template "chk_dpl.yaml" for example:
- it's requesting that 3 replicas, or 3 instances of the Pod, are running at any given time
- it shows two `spec` fields (`spec` and `spec.template.spec`), and the Pods
are created using the Pod Template defined in `spec.template`
- the nested object, such as the `Pod` being part of a `Deployment`, retains
its `metadata` and `spec` and loses the `apiVersion` and `kind` - both being
replaced by `template`
- in `spec.template.spec`, it defines the desired state of the `Pod`, for whose `Pod`
creates a single container running the `nginx:latest` image from Docker Hub

Once the Deployment object is created, the Kubernetes system attaches the `status`
field to the object and populates it with all necessary status fields.


## Namespace
- names of the resources/objects created inside a `Namespace` are unique, but
not across namespaces in the cluster
- Kubernetes creates 4 namespaces out of the box generally:
  - `default` contains the objects and resources created by administrators and developers, and objects
  are assigned to it by default unless another namespace name is provided by the user
  - `kube-system` contains the objects created by the Kubernetes system, mostly the control plane agents
  - `kube-public` is a special namespace, which is unsecured and readable by anyone, used for special
  purposes such as exposing public (non-sensitive) information about the cluster
  - `kube-node-lease` is the newest, which holds node lease objects used for node heartbeat data
- the good practice is to create additional namespaces, as desired, to virtualize the
cluster and isolate users, developer teams, applications, or tiers
- secures its lead against competitors, as it provides a solution to the multi-tenancy requirement of
today's enterprise development teams

Scenario when to use `Namespace`:
1. Structure your components
2. Avoid conflicts between teams
3. Share services between different environments
4. Access and Resource Limits on Namespace level


## ReplicaSet
- implements the replication and self-healing aspects of the ReplicationController
- supports both equality- and set-based Selectors
- detects and ensures that the current state matches the desired state
- can be used independently as Pod controllers but they only offer a limited set of features


## Deployment
- provides declarative updates to Pods and ReplicaSets
- allows for seamless application updates and rollbacks through `rollout`, and it
directly manages its ReplicaSets for application scaling
- abstraction over Pods
- database can't be replicated by `Deployment` since it's stateful, which should be handled by `StatefulSet`
- `Deployment` for stateLESS apps; while `StatefulSet` for stateFUL apps or databases


## Service
- can expose single `Pod`, `ReplicaSet`, `Deployment`, `DaemonSet`, and `StatefulSet`
- stable IP address
- lifecycle of `Pod` and `Service` are not connected
- request goes into `Ingress` first then forwarding to `Service`
- load balancing
- loose coupling
- with & outside cluster

Types: ClusterIP, NodePort, LoadBalancer, Headless, ExternalName

### ClusterIP
The ClusterIP service type is the default, and only provides access internally
(except if manually creating an external endpoint).

The range of ClusterIP used is defined via an API server startup option.
The `kubectl proxy` command creates a local service to access a ClusterIP.
This can be useful for troubleshooting or development work.

### NodePort
The NodePort type is great for debugging, or when a static IP address is necessary,
such as opening a particular address through a firewall.

The NodePort range is defined in the cluster configuration.

### LoadBalancer
The LoadBalancer service was created to pass requests to a cloud provider like GKE or AWS.
Private cloud solutions also may implement this service type if there is a cloud
provider plugin, such as with CloudStack and OpenStack.

Even without a cloud provider, the address is made available to public traffic,
and packets are spread among the Pods in the deployment automatically.

### Headless
When no load-balancing or a single Service IP is needed, create a "headless" service
by explicitly specifying "None" for the cluster IP.

For headless services, a cluster IP is not allocated, kube-proxy does not handle these
services, and there is no load balancing or proxying done by the platform for them.

### ExternalName
It has no selectors, nor does it define ports or endpoints.
It allows the return of an alias to an external service.
The redirection happens at the DNS level, not via a proxy or forward.
This object can be useful for services not yet brought into the Kubernetes cluster.
A simple change of the type in the future would redirect traffic to the internal objects.
As CoreDNS has become more stable, this service is not used as much.


## Pod
- the smallest and simplest Kubernetes object
- the unit of deployment in Kubernetes, which represents a single instance of the application
- a logical collection of one or more containers, which:
  - are scheduled together on the same host with the Pod
  - share the same network namespace, meaning that they share a single IP address originally assigned to the Pod
  - have access to mount the same external storage (volumes)
- ephemeral in nature, and they do not have the capability to self-heal themselves
- abstraction over container
- usually 1 application per pod
- each pod gets its own IP address
- new IP address on re-creation

### Multi-Container Pod
Every container in a Pod shares a single IP address and namespace.
Each container has equal potential access to storage given to the Pod.
Kubernetes does not provide any locking, so your configuration or application
should be such that containers do not have conflicting writes.

One container could be read only while the other writes.
Containers could be configured to write to different directories in the volume,
or the application could have built in locking.
Without these protections, there would be no way to order containers writing to the storage.

There are three terms often used for multi-container pods: _ambassador_, _adapter_, and _sidecar_.
Each term is an expression of what a secondary pod is intended to do.
All are just multi-container pods.

#### Ambassador
It's used to communicate with outside resources, often outside the cluster.

Using a proxy, like Envoy or other, to embed a proxy instead of using one provided
by the cluster, which is helpful if one is unsure of the cluster configuration.

It allows for access to the outside world without having to implement a service
or another entry in an ingress controller: proxy local connection, reverse proxy,
limits HTTP requests, re-route from the main container to the outside world.​

#### Adapter
It's useful to modify the data generated by the primary container.

The basic purpose of an adapter container is to modify data, either on ingress
or egress, to match some other need.

An adapter would be an efficient way to standardize the output of the main
container to be ingested by the monitoring tool, without having to modify the
monitor or the containerized application.

An adapter container transforms multiple applications to singular view.
For example, the Microsoft version of ASCII is distinct from everyone else.
It's needed to modify a datastream for proper use.

#### Sidecar
Similar to a sidecar on a motorcycle, it does not provide the main power,
but it does help carry stuff.

The idea for a sidecar container is to add some functionality not present in the
main container.

A sidecar is a secondary container which helps or provides a service not found in the primary application.
Logging containers are a common sidecar.


## Label
- key-value pairs attached to Kubernetes objects (e.g. Pods, ReplicaSets, Nodes, Namespaces, Persistent Volumes)
- are used to organize and select a subset of objects, based on the requirements in place
- many objects can have the same Label(s), which means Label do not provide uniqueness to objects
- Controllers use Labels to logically group together decoupled objects, rather than using objects' names or IDs

__Label__ or __Annotation__ is used to attach metadata to Kubernetes objects.

__Label__ is intended to be used to specify identifying attributes of objects
that are meaningful and relevant to users, but do not directly imply semantics
to the core system.

However, __Annotation__ is normally for arbitrary non-identifying metadata attachment to objects.

__Label__ can be used to select objects and to find collections of objects that satisfy
certain conditions, while __Annotation__ is not used to identify and select objects.


## Volume
A `Volume` is essentially a mount point on the container's file system backed by a storage medium.
In Kubernetes, a `Volume` is linked to a Pod and can be shared among the containers of that Pod.

For volume shared, note that one container wrote, and the other container had immediate access to the data.
There is nothing to keep the containers from overwriting the other’s data.
Locking or versioning considerations must be part of the application to avoid corruption.

Type:
- "emptyDir":
  - an empty Volume is created for the Pod as soon as it is scheduled on the
  worker node, whose life is tightly coupled with the Pod (if the Pod is terminated,
  the content of emptyDir is deleted forever)
  - an empty directory that gets erased when the Pod dies, but is recreated when the container restarts
- "hostPath":
  - it shares a directory between the host and the Pod, the content of the Volume
  is still available on the host when the Pod is terminated
  - it mounts a resource from the host node filesystem
    - where the resource could be a directory, file socket, character, or block device
    - these resources must already exist on the host to be used
    - there are two types, "DirectoryOrCreate" and "FileOrCreate", which create
    the resources on the host, and use them if they don't already exist
- "gcePersistentDisk": It mounts a Google Compute Engine (GCE) persistent disk
- "awsElasticBlockStore": It mounts an AWS EBS Volume
- "azureDisk": It mounts a Microsoft Azure Data Disk
- "azureFile": It mounts a Microsoft Azure File Volume
- "cephfs": It mounts an existing CephFS volume, when a Pod terminates, the
  volume is unmounted and the contents of the volume are preserved
- "nfs": It mounts an NFS (Network File System) share
- "iscsi": It mounts an iSCSI (Internet Small Computer System Interface) share
- "secret": It can pass sensitive information, such as passwords, to Pods
- "configMap": It provides configuration data, or shell commands and arguments into a Pod
- "persistentVolumeClaim": It can be used to attach a PersistentVolume to a Pod

### Persistent Volume
In a typical IT environment, storage is managed by the storage/system administrators.
The end user will just receive instructions to use the storage but is not involved
with the underlying storage management.

Kubernetes resolves this problem with the `PersistentVolume` (PV) subsystem, which
provides APIs for users and administrators to manage and consume persistent storage.

`PersistentVolume` can be dynamically provisioned based on the `StorageClass` resource.
A `StorageClass` contains pre-defined provisioners and parameters to create a `PersistentVolume`.
Using `PersistentVolumeClaim`, a user sends the request for dynamic PV creation,
which gets wired to the `StorageClass` resource.

A `PersistentVolume` (PV) is a storage abstraction used to retain data longer than the `Pod` using it.
Pods define a volume of type `PersistentVolumeClaim` (PVC) with various parameters
for size and possibly the type of backend storage known as its `StorageClass`.
The cluster then attaches the `PersistentVolume`.

Kubernetes will dynamically use volumes that are available, irrespective of its
storage type, allowing claims to any backend storage.

Phases of Persistent Storage:
- Provisioning
- Binding
- Using
- Releasing
- Reclaiming

### Persistent Volume Claims
A `PersistentVolumeClaim` (PVC) is a request for storage by a user.
Users request for `PersistentVolume` resources based on type, access mode, and size.
There are three access modes:
- ReadWriteOnce (read-write by a single node)
- ReadOnlyMany (read-only by many nodes)
- ReadWriteMany (read-write by many nodes)

Once a suitable `PersistentVolume` is found, it is bound to a `PersistentVolumeClaim`.
After a successful bound, the `PersistentVolumeClaim` resource can be used by the containers of the `Pod`.

Once a user finishes its work, the attached `PersistentVolume`s can be released.
The underlying `PersistentVolume`s can then be reclaimed (for an admin to verify and/or aggregate data),
deleted (both data and volume are deleted), or recycled for future usage (only data is deleted),
based on the configured `persistentVolumeReclaimPolicy` property.


## NetworkPolicy
### Ingress
An `Ingress` is a collection of rules that allow inbound connections to reach the cluster Services.

To allow the inbound connection to reach the cluster services, `Ingress` configures
a Layer 7 HTTP/HTTPS load balancer for Services and provides the following:
- TLS (Transport Layer Security)
- Name-based virtual hosting
- Fanout routing
- Loadbalancing
- Custom rules

The `Ingress` resource does not do any request forwarding by itself, it merely
accepts the definitions of traffic routing rules.
The ingress is fulfilled by an Ingress Controller, which is a reverse proxy responsible
for traffic routing based on rules defined in the `Ingress` resource.

An Ingress Controller is an application watching the Master Node's API server for changes
in the `Ingress` resources and updates the Layer 7 Load Balancer accordingly.
Ingress Controllers are also know as Controllers, Ingress Proxy, Service Proxy, Revers Proxy, etc.
