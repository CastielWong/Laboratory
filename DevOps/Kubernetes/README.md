
- [Concept](#concept)
  - [Container Orchestration](#container-orchestration)
- [Architecture](#architecture)
  - [etcd](#etcd)
  - [Container Runtime](#container-runtime)
- [Object Model / Component](#object-model--component)
  - [Pod](#pod)
  - [Label](#label)
  - [ReplicaSet](#replicaset)
  - [Deployment](#deployment)
  - [Namespace](#namespace)
  - [Service](#service)
  - [Sample](#sample)
- [Access Control](#access-control)
  - [Authentication](#authentication)
  - [Authorization](#authorization)
- [Configuration](#configuration)
- [Reference](#reference)

"Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications." It's an open source container orchestration framework/tool.

To access and manage Kubernetes resources or objects in the cluster, we need to access a specific API endpoint on the API server. Each access request goes through the following access control stages (Authentication -> Authorization -> Admission Control):
- Authentication: Logs in a user
- Authorization: Authorizes the API requests submitted by the authenticated user
- Admission Control: Software modules that validate and/or modify user requests based


## Concept

### Container Orchestration
In Development (Dev) environments, running containers on a single host for development and testing of applications may be an option. However, when migrating to Quality Assurance (QA) and Production (Prod) environments, that is no longer a viable option because the applications and services need to meet specific requirements:

- Fault-tolerance
-On-demand scalability
- Optimal resource usage
- Auto-discovery to automatically discover and communicate with each other
- Accessibility from the outside world
- Seamless updates/rollbacks without any downtime.

__Container orchestrators__ are tools which group systems together to form clusters where containers' deployment and management is automated at scale while meeting the requirements mentioned above.

Container orchestration tool:
- Amazon Elastic Container Service: ECS is a hosted service provided by Amazon Web Services (AWS) to run Docker containers at scale on its infrastructure.
- Azure Container Instances: Azure Container Instance (ACI) is a basic container orchestration service provided by Microsoft Azure.
- Azure Service Fabric: it is an open source container orchestrator provided by Microsoft Azure.
- Kubernetes: it is an open source orchestration tool, originally started by Google, today part of the Cloud Native Computing Foundation (CNCF) project.
- Marathon: it is a framework to run containers at scale on Apache Mesos.
- Nomad: it is the container and workload orchestrator provided by HashiCorp.
- Docker Swarm: it is a container orchestrator provided by Docker, Inc. It is part of Docker Engine.

Kubernetes as-a-Service solution:
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)
- DigitalOcean Kubernetes
- Google Kubernetes Engine (GKE)
- IBM Cloud Kubernetes Service
- Oracle Container Engine for Kubernetes
- VMware Tanzu Kubernetes Grid


## Architecture

A master node runs following control plane components:
- API Server
- Scheduler
- Controller Managers
- Data Store

In addition, the master node runs:
- Container Runtime
- Node Agent
- Proxy

Master Processes:
- API Server
  - is load balanced
- Scheduler
- Controller Manager
- etcd
  - is the cluster brain
  - cluster changes get stored in the key value store
  - application data is not stored in
  - distributed storage across all master nodes
  - holds the current status of any Kubernetes component

Node Processes:
- kubelet
  - interacts with both the container and node
  - starts the pod with a container inside
- Kube Proxy forwards the requests
- Container runtime

### etcd
To persist the Kubernetes cluster's state, all cluster configuration data is saved to etcd. etcd is a distributed key-value store which only holds cluster state related data, no client workload data. etcd may be configured on the master node (stacked topology), or on its dedicated host (external topology) to help reduce the chances of data store loss by decoupling it from the other control plane agents.

With stacked etcd topology, HA master node replicas ensure the etcd data store's resiliency as well. However, that is not the case with external etcd topology, where the etcd hosts have to be separately replicated for HA, a configuration that introduces the need for additional hardware.

### Container Runtime
Although Kubernetes is described as a "container orchestration engine", it does not have the capability to directly handle containers. In order to manage a container's lifecycle, Kubernetes requires a __container runtime__ on the node where a Pod and its containers are to be scheduled. Kubernetes supports many container runtimes:
- Docker: although a container platform which uses "containerd" as a container runtime, it is the most popular container runtime used with Kubernetes
- CRI-O: a lightweight container runtime for Kubernetes, it also supports Docker image registries
- containerd: a simple and portable container runtime providing robustness
- frakti: a hypervisor-based container runtime for Kubernetes


## Object Model / Component
Kubernetes has a very rich object model, representing different persistent entities in the Kubernetes cluster. Those entities describe:
- What containerized applications running
- The nodes where the containerized applications are deployed
- Application resource consumption
- Policies attached to applications, like restart/upgrade policies, fault tolerance, etc

With each object, the intent or the desired state of the object, is declared in the `spec` section. The Kubernetes system manages the `status` section for objects, where it records the actual state of the object.
At any given point in time, the Kubernetes Control Plane tries to match the object's actual state to the object's desired state.

When creating an object, the object's configuration data section from below the `spec` field has to be submitted to the Kubernetes API server. The API request to create an object must have the `spec` section, describing the desired state, as well as other details.
Although the API server accepts object definition files in a JSON format, most often it's suggested to provide such files in a YAML format, which is converted by `kubectl` in a JSON payload and sent to the API server.

The default recommended controller is the Deployment which configures a ReplicaSet controller to manage Pod's lifecycle.

Layers of abstraction:
- Deployment manages a ReplicateSet
- ReplicateSet manages a Pod
- Pod is an abstraction of Container

### Pod
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

### Label
- key-value pairs attached to Kubernetes objects (e.g. Pods, ReplicaSets, Nodes, Namespaces, Persistent Volumes)
- are used to organize and select a subset of objects, based on the requirements in place
- many objects can have the same Label(s), which means Label do not provide uniqueness to objects
- Controllers use Labels to logically group together decoupled objects, rather than using objects' names or IDs

### ReplicaSet
- implements the replication and self-healing aspects of the ReplicationController
- supports both equality- and set-based Selectors
- detect and ensures that the current state matches the desired state
- can be used independently as Pod controllers but they only offer a limited set of features

### Deployment
- provides declarative updates to Pods and ReplicaSets
- allows for seamless application updates and `rollbacks` through `rollouts` and `rollbacks`, and it directly manages its ReplicaSets for application scaling
- abstraction over Pods
- database can't be replicated by Deployment since it's stateful, which should be handled by StatefulSet
- Deployment for stateLESS apps; while StatefulSet for stateFUL apps or databases

### Namespace
- names of the resources/objects created inside a Namespace are unique, but not across Namespaces in the cluster
- Kubernetes creates four Namespaces out of the box generally:
  - `kube-system` contains the objects created by the Kubernetes system, mostly the control plane agents
  - `kube-public` is a special Namespace, which is unsecured and readable by anyone, used for special purposes such as exposing public (non-sensitive) information about the cluster
  - `kube-node-lease` is the newest, which holds node lease objects used for node heartbeat data
  - `default` contains the objects and resources created by administrators and developers, and objects are assigned to it by default unless another Namespace name is provided by the user
- the good practice is to create additional Namespaces, as desired, to virtualize the cluster and isolate users, developer teams, applications, or tiers
- secures its lead against competitors, as it provides a solution to the multi-tenancy requirement of today's enterprise development teams

Scenario when to use Namespace:
1. Structure your components
2. Avoid conflicts between teams
3. Share services between different environments
4. Access and Resource Limits on Namespace level

### Service
- can expose single Pods, ReplicaSets, Deployments, DaemonSets, and StatefulSets
- stable IP address
- lifecycle of Pod and Service are not connected
- request goes into Ingress first then forwarding to Service
- loadbalancing
- loose coupling
- with & outside cluster

Four types:
- ClusterIP
- Headless
- NodePort
- LoadBalancer


### Sample
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.11
        ports:
        - containerPort: 80
```

The `apiVersion` field is the first required field, and it specifies the API endpoint on the API server which we want to connect to; it must match an existing version for the object type defined.

The second required field is `kind`, specifying the object type - in our case it is `Deployment`, but it can be `Pod`, `Replicaset`, `Namespace`, `Service`, etc.

The third required field `metadata`, holds the object's basic information, such as `name`, `labels`, `namespace`, etc. The example shows two `spec` fields (`spec` and `spec.template.spec`).

The fourth required field `spec` marks the beginning of the block defining the desired state of the Deployment object. In the example, it's requesting that 3 replicas, or 3 instances of the Pod, are running at any given time. The Pods are created using the Pod Template defined in `spec.template`.
A nested object, such as the `Pod` being part of a `Deployment`, retains its `metadata` and `spec` and loses the `apiVersion` and `kind` - both being replaced by `template`. In `spec.template.spec`, it defines the desired state of the `Pod`, for whose `Pod` creates a single container running the `nginx:1.15.11` image from Docker Hub.

Once the Deployment object is created, the Kubernetes system attaches the `status` field to the object and populates it with all necessary status fields.


## Access Control
To access and manage Kubernetes resources or objects in the cluster, it's needed to access a specific API endpoint on the API server. Each access request goes through the following access control stages:
1. Authentication: Logs in a user
2. Authorization: Authorizes the API requests submitted by the authenticated user
3. Admission Control: Software modules that validate and/or modify user requests based

### Authentication
Kubernetes uses a series of authentication modules:
- X509 Client Certificates:
  To enable client certificate authentication, it's needed to reference a file containing one or more certificate authorities by passing the `--client-ca-file=SOMEFILE` option to the API server.
  The certificate authorities mentioned in the file would validate the client certificates presented by users to the API server.
- Static Token File:
  Passing a file containing pre-defined bearer tokens with the `--token-auth-file=SOMEFILE` option to the API server.
  Currently, these tokens would last indefinitely, and they cannot be changed without restarting the API server.
- Bootstrap Tokens:
  Tokens used for bootstrapping new Kubernetes clusters.
- Service Account Tokens:
  Automatically enabled authenticators that use signed bearer tokens to verify requests.
  These tokens get attached to Pods using the ServiceAccount Admission Controller, which allows in-cluster processes to talk to the API server.
- OpenID Connect Tokens:
  OpenID Connect helps to connect with OAuth2 providers, such as Azure Active Directory, Salesforce, and Google, to offload the authentication to external services.
- Webhook Token Authentication:
  With Webhook-based authentication, verification of bearer tokens can be offloaded to a remote service.
- Authenticating Proxy:
  Allows for the programming of additional authentication logic.

### Authorization
- Node
- ABAC (Attribute-Based Access Control)
- Webhook
- RBAC (Role-BasedAccess Control)
  - Role: grants access to resources within a specific Namespace
  - ClusterRole: grants the same permissions as Role does, but its scope is cluster-wide


## Configuration
Configuration file: Connecting Deployments to Service to Pod.

Each configuration has three parts:
- metadata
- specification
- status, which is generated and added automatically by Kubernetes


## Reference
- Introduction to Kubernetes: https://learning.edx.org/course/course-v1:LinuxFoundationX+LFS158x+3T2020/
- Kubernetes Tutorial for Beginners: https://www.youtube.com/watch?v=X48VuDVv0do
