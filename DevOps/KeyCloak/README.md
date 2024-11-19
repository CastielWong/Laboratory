
This is the demo project for KeyCloak.

- [Recipe](#recipe)
- [Usage](#usage)
- [Reference](#reference)


[KeyCloak](https://www.keycloak.org) is a popular open-source identity and access management solution.

Basic concepts:
- realm: separated space for managing objects like users, applications, and role
- client: application (web/mobile application/service) which requires authentication
- user: individual who will authenticate against KeyCloak
- role: define permissions and access levels for users


## Recipe
| Command    | Description                              |
|------------|------------------------------------------|
| make start | launch up container(s) for demo          |
| make end   | stop all relative container(s)           |
| make clean | clean up container(s), volume(s) created |


## Usage
After containers are up, access to KeyCloak via "http://localhost:7080"

Follow official guides below for more details:
- Docker: https://www.keycloak.org/getting-started/getting-started-docker
  - create realm, user
  - create client to secure application


## Reference
- Running Keycloak in a container: https://www.keycloak.org/server/containers
- Health Check: https://keycloak.org/server/health
- Metrics: https://keycloak.org/server/configuration-metrics
