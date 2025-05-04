
- [Concept](#concept)
  - [Container Orchestration](#container-orchestration)
- [Architecture](#architecture)
  - [etcd](#etcd)
  - [Container Runtime](#container-runtime)
- [Access Control](#access-control)
  - [Authentication](#authentication)
  - [Authorization](#authorization)
- [Configuration](#configuration)
- [Reference](#reference)


"Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications."
It's an open source container orchestration framework/tool.

## Concept

### Container Orchestration
In Development (Dev) environments, running containers on a single host for development and testing of applications may be an option.
However, when migrating to Quality Assurance (QA) and Production (Prod) environments, that is no longer a viable option because the applications and services need to meet specific requirements:
- fault-tolerance
- on-demand scalability
- optimal resource usage
- auto-discovery to automatically discover and communicate with each other
- accessibility from the outside world
- seamless updates/rollbacks without any downtime

__Container orchestrators__ are tools which group systems together to form clusters where containers' deployment and management is automated at scale while meeting the requirements mentioned above.

Container orchestration tool:
- Amazon Elastic Container Service: a hosted service provided by Amazon Web Services (AWS) to run Docker containers at scale on its infrastructure
- Azure Container Instances: a basic container orchestration service provided by Microsoft Azure
- Azure Service Fabric: an open source container orchestrator provided by Microsoft Azure
- Kubernetes: an open source orchestration tool, originally started by Google, today part of the Cloud Native Computing Foundation (CNCF) project
- Marathon: a framework to run containers at scale on Apache Mesos
- Nomad: a container and workload orchestrator provided by HashiCorp
- Docker Swarm: a container orchestrator provided by Docker, Inc, which is part of Docker Engine

Kubernetes as-a-Service solution:
- Amazon Elastic Kubernetes Service (EKS)
- Azure Kubernetes Service (AKS)
- Google Kubernetes Engine (GKE)
- Digital Ocean Kubernetes
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
To persist the Kubernetes cluster's state, all cluster configuration data is saved to __etcd__.
__etcd__ is a distributed key-value store which only holds cluster state related data, no client workload data.
__etcd__ may be configured on the master node (stacked topology), or on its dedicated host (external topology) to help reduce the chances of data store loss by decoupling it from the other control plane agents.

With stacked __etcd__ topology, High Availability (HA) master node replicas ensure the __etcd__ data store's resiliency as well.
However, that is not the case with external __etcd__ topology, where the __etcd__ hosts have to be separately replicated for HA, a configuration that introduces the need for additional hardware.

### Container Runtime
A container runtime is the component which runs the containerized application upon request.
Docker Engine remains the default for Kubernetes, though CRI-O and others are gaining community support.
Although Kubernetes is described as a "container orchestration engine", it does not have the capability to directly handle containers.
In order to manage a container's lifecycle, Kubernetes requires a __container runtime__ on the node where a Pod and its containers are to be scheduled.

Kubernetes supports many container runtimes:
- Docker: although a container platform which uses "containerd" as a container runtime, it is the most popular container runtime used with Kubernetes
- CRI-O: Container Runtime Interface, a lightweight OCI-compatible (Open Container Initiative) container runtime for Kubernetes, it also supports Docker image registries
- containerd: a simple and portable container runtime providing robustness
- frakti: a hypervisor-based container runtime for Kubernetes


## Access Control
To access and manage Kubernetes resources or objects in the cluster, it's needed to access a specific API endpoint on the API server.
Each access request goes through the following access control stages, where:
1. __Authentication__: Logs in a user
2. __Authorization__: Authorizes the API requests submitted by the authenticated user
3. __Admission Control__: Software modules that validate and/or modify user requests based

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

There are three main points to remember with authentication in Kubernetes:
- In its straightforward form, authentication is done with certificates, tokens or basic authentication (i.e. username and password)
- Users are not created by the API, but should be managed by the operating system or an external server
- System accounts are used by processes to access the API


### Authorization
- Node
- ABAC (Attribute-Based Access Control)
- Webhook
- RBAC (Role-Based Access Control)
  - Role: grants access to resources within a specific Namespace
  - ClusterRole: grants the same permissions as Role does, but its scope is cluster-wide



## Configuration
Configuration file: Connecting Deployments to Service to Pod.

Each configuration has three parts:
- metadata
- specification
- status, which is generated and added automatically by Kubernetes



## Reference
- Glossary: https://kubernetes.io/docs/reference/glossary
- Introduction to Kubernetes: https://learning.edx.org/course/course-v1:LinuxFoundationX+LFS158x+3T2020/
- Kubernetes Tutorial for Beginners: https://www.youtube.com/watch?v=X48VuDVv0do
- CKAD:
  - exercise: https://github.com/dgkanatsios/CKAD-exercises
  - challenge: https://codeburst.io/kubernetes-ckad-weekly-challenges-overview-and-tips-7282b36a2681
  - network: https://editor.cilium.io
- Illustrated Guide To Kubernetes Networking: https://speakerdeck.com/thockin/illustrated-guide-to-kubernetes-networking
- Graceful shutdown in Kubernetes: https://learnk8s.io/graceful-shutdown
