
This exercise guide assumes the following environment, which by default uses the certificate and key from "/var/lib/minikube/certs/", and RBAC mode for authorization:
- Minikube v1.13.1
- Kubernetes v1.19.2
- Docker 19.03.12-ce

Start Minikube: `minikube start`

View the content of the `kubectl` client's configuration manifest, observing the only context `minikube` and the only user `minikube`, created by default: `kubectl config view`

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/student/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/student/.minikube/profiles/minikube/client.crt
    client-key: /home/student/.minikube/profiles/minikube/client.key
```

Create "lfs158" namespace: `kubectl create namespace lfs158`

Create the rbac directory and cd into it:

```sh
mkdir rbac

cd rbac/
```

Create a _private key _for the "student" user with `openssl` tool, then create a _certificate signing request_ for the "student" user with `openssl` tool:

```sh
openssl genrsa -out student.key 2048

openssl req -new -key student.key -out student.csr -subj "/CN=student/O=learner"
```

Create a YAML manifest for a _certificate signing request_ object, and save it with a blank value for the "request" field: `vim signing-request.yaml`

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: student-csr
spec:
  groups:
  - system:authenticated
  request: <assign encoded value from next cat command>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - digital signature
  - key encipherment
  - client auth
```

View the __certificate__, encode it in `base64`: `cat student.csr | base64 | tr -d '\n','%'`

And assign it to the "request" field in the "signing-request.yaml" file `vim signing-request.yaml`:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: student-csr
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUd...1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - digital signature
  - key encipherment
  - client auth
```

Create the _certificate signing request_ object, then list the _certificate signing request_ objects. It shows a "pending" state:

```sh
kubectl create -f signing-request.yaml

kubectl get csr
```

Approve the _certificate signing request_ object, then list the _certificate signing request_ objects again. It shows both "approved" and "issued" states:

```sh
kubectl certificate approve student-csr

kubectl get csr
```

Extract the approved __certificate__ from the _certificate signing request_, decode it with `base64` and save it as a certificate file. Then view the certificate in the newly created certificate file:

```sh
kubectl get csr student-csr -o jsonpath='{.status.certificate}' | base64 --decode > student.crt

cat student.crt
```


Configure the `kubectl` client's configuration manifest with the "student" user's credentials by assigning the "key" and "certificate": `kubectl config set-credentials student --client-certificate=student.crt --client-key=student.key`

Create a new "context" entry in the `kubectl` client's configuration manifest for the "student" user, associated with the "lfs158" namespace in the `minikube` cluster: `kubectl config set-context student-context --cluster=minikube --namespace=lfs158 --user=student`


View the contents of the `kubectl` client's configuration manifest again, observing the new "context" entry "student-context", and the new "user" entry "student": `kubectl config view`

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/student/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
- context:
    cluster: minikube
    namespace: lfs158
    user: student
  name: student-context
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/student/.minikube/profiles/minikube/client.crt
    client-key: /home/student/.minikube/profiles/minikube/client.key
- name: student
  user:
    client-certificate: /home/student/rbac/student.crt
    client-key: /home/student/rbac/student.key
```

While in the default minikube context, create a new "deployment" in the "lfs158" namespace: `kubectl -n lfs158 create deployment nginx --image=nginx:alpine`


From the new context "student-context" try to list pods. The attempt fails because the "student" user has no permissions configured for the "student-context": `kubectl --context=student-context get pods`

> Error from server (Forbidden): pods is forbidden: User "student" cannot list resource "pods" in API group "" in the namespace "lfs158"

The following steps will assign a limited set of permissions to the "student" user in the "student-context".


Create a YAML configuration manifest for a "pod-reader" Role object, which allows only __get__, __watch__, __list__ actions in the "lfs158" namespace against "pod" objects. Then create the role object and list it from the default minikube context, but from the "lfs158" namespace `vim role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: lfs158
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

```sh
kubectl create -f role.yaml

kubectl -n lfs158 get roles
```


Create a YAML configuration manifest for a "rolebinding" object, which assigns the permissions of the "pod-reader" Role to the "student" user. Then create the "rolebinding" object and list it from the default minikube context, but from the "lfs158" namespace `vim rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-read-access
  namespace: lfs158
subjects:
- kind: User
  name: student
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```


```sh
kubectl create -f rolebinding.yaml

kubectl -n lfs158 get rolebindings
```


Now that we have assigned permissions to the "student" user, we can successfully list pods from the new context "student-context": `kubectl --context=student-context get pods`
