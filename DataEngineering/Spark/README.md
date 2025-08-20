
- [Logical Component](#logical-component)


## Logical Component

Driver -> Master -> Worker -> Executor

Driver submits the app, while Master assigns resources.

- __Executors__ are JVM processes launched by __Workers__ but communicate directly with
__Driver__ for task execution
- __Master__ is technically optional in some modes (e.g., Kubernetes uses k8s API server instead)

| Component | Logical Role           | Physical Manifestation   | Communication               |
|-----------|------------------------|--------------------------|-----------------------------|
| Driver    | application controller | process on any node      | Talks to Master & Executors |
| Master    | resource authority     | dedicated process        | Listens to Drivers, Workers |
| Worker    | Executor launcher      | process on compute nodes | Reports to Master           |
| Executor  | task executor          | JVM within Worker node   | Talks to Driver directly    |
