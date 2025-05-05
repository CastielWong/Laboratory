
- [Common Command](#common-command)
- [Installation](#installation)
  - [Linux](#linux)
    - [Ubuntu](#ubuntu)
    - [CentOS](#centos)
  - [MacOS](#macos)
    - [Homebrew](#homebrew)
- [CRI-O](#cri-o)
  - [HyperKit](#hyperkit)
- [Reference](#reference)


Minikube CLI is used for start/delete the cluster; while Kubectl CLI is used for configuring the Minikube cluster.

## Common Command
Minikube uses Docker as its default container runtime.

```sh
minikube addons list

minikube addons enable {addon}

# docker daemon like Docker Desktop should be up and running when the driver is docker
minikube start --driver=docker

minikube status
minikube config view

minikube addons list

minikube addons enable {addon}

# get into minikube to install tool needed
minikube ssh

# get driver
minikube profile list

minikube stop

# access to http://localhost:{port}/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
minikube dashboard


# check the external IP of minikube exposed
minikube ip
#  access service created
minikube service {svc}


## delete all
minikube delete --purge --all
```



## Installation
### Linux
Verify the virtualization support on your Linux OS (a non-empty output indicates supported virtualization):
`grep -E --color 'vmx|svm' /proc/cpuinfo`

Firstly, it's needed to install the VirtualBox hypervisor.
Then download the latest release or a specific release from the Minikube release page, note that replacing "/latest/" with a particular version, such as "/v1.13.0/" will download that specified version.

After Minikube is installed, start it with the `minikube start` command, that bootstraps a single-node cluster with the latest stable Kubernetes version release.
For a specific Kubernetes version the `--kubernetes-version` option can be used as such `minikube start --kubernetes-version v1.19.0` (where `latest` is default and acceptable version value, and `stable` is also acceptable).

#### Ubuntu
```sh
# install VirtualBox
# add the source repository for the bionic distribution (Ubuntu 18.04), download and register the public key, update and install
sudo bash -c 'echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib" >> /etc/apt/sources.list'

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

sudo apt update

sudo apt install -y virtualbox-{version}

# download minikube then make it executable and add it to PATH to install
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

#### CentOS
```sh
# install VirtualBox
sudo yum install kernel-devel kernel-devel-$(uname -r) kernel-headers kernel-headers-$(uname -r) make patch gcc

sudo wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d

sudo yum update

sudo yum install VirtualBox-{version}

# verify if the installation is successful
systemctl status vboxdrv

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm

sudo rpm -Uvh minikube-latest.x86_64.rpm
```


### MacOS
Verify the virtualization support on the macOS (VMX in the output indicates enabled virtualization):
`sysctl -a | grep -E --color 'machdep.cpu.features|VMX'`

Although VirtualBox is the default hypervisor for Minikube, on Mac OS X we can configure Minikube at startup to use another hypervisor (downloaded separately), with the `--driver=parallels` or `--driver=hyperkit` start option.

Download VirtualBox from its website then have it installed.

Either install it directly or via Homebrew is feasible:
- directly: `curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/`
- Homebrew: `brew install minikube`

#### Homebrew
```sh
# install the vm
brew install hyperkit
# install the driver
brew install docker-machine-driver-hyperkit
# grant superuser privileges since it is required to access the hypervisor
sudo chown root:wheel /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit
sudo chmod u+s /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit
# install the minikube
brew install minikube

# remove existing cluster in case conflict
# minikube delete

minikube start --driver=hyperkit

kubectl get nodes
```



## CRI-O
According to the [CRI-O website](https://cri-o.io/), CRI-O is an implementation of the Kubernetes CRI (Container Runtime Interface) to enable using OCI (Open Container Initiative) compatible runtimes."

Start Minikube with CRI-O as container runtime, instead of Docker, with the following command:
`minikube start --container-runtime cri-o`

NOTE: While docker is the default runtime, minikube Kubernetes also supports `cri-o` and `containerd`.

By describing a running Kubernetes pod, it's feasible to extract the Container ID field of the pod that includes the name of the runtime:
`kubectl -n kube-system describe pod kube-scheduler-minikube | grep "Container ID"`

### HyperKit
Minikube would uses the HyperKit hypervisor to create a virtual machine that runs the K8S cluster,
which means minikube can work without external Docker like Docker Desktop at all.

When HyperKit is the VM driver, run `eval $(minikube docker-env)` to point the shell to minikube's
docker-daemon to check through images/containers.


## Reference
- How to Install VirtualBox on CentOS 7: https://linuxize.com/post/how-to-install-virtualbox-on-centos-7/
- minikube start: https://minikube.sigs.k8s.io/docs/start/
- Install Minikube: https://k8s-docs.netlify.app/en/docs/tasks/tools/install-minikube/
