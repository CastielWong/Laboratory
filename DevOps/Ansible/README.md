
- [Common Command](#common-command)
- [Local Check](#local-check)
- [Reference](#reference)


Ansible provides open-source automation that reduces complexity and runs everywhere,
which lets user automate virtually any task.

Ansible uses simple, human-readable scripts called playbooks to automate tasks.
Declaring the desired state of a local or remote system in the playbook.
Ansible ensures that the system remains in that state.

As automation technology, Ansible is designed around the following principles:
- agent-less architecture
- simplicity
- scalability and flexibility
- idempotence and predictability

Most Ansible environments have three main components:
- Control node: a system on which Ansible is installed, where to run Ansible commands
such as ansible or ansible-inventory on a control node
- Inventory: a list of managed nodes that are logically organized, which is created
on the control node to describe host deployments to Ansible
- Managed node: a remote system, or host, that Ansible controls


## Common Command
```sh
ansible-inventory -i {inventory}.ini --list

ansible {host} -m ping -i {inventory}.ini

ansible-playbook -i inventory.ini playbook.yaml
```


## Local Check
Utilize Minikube or similar to launch up containers to try the usage of Ansible.

```sh
# set env to ensure the Python interpreter running Ansible is correct
export ANSIBLE_PYTHON_INTERPRETER={python_env}/bin/python

# "kubernetes" is needed for Ansible to interact with K8S cluster
pip install kubernetes

# run the playbook prepared
ansible-playbook -i inventory.ini nginx-playbook.yaml
```

Check the IP of Minikube via `minikube ip`, then access to "{IP}:30010" for verification.


## Reference
- Ansible vs Kubernetes: What's the Difference: https://www.theknowledgeacademy.com/blog/ansible-vs-kubernetes
