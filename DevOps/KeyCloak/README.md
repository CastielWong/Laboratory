
This is the demo project for KeyCloak.

- [Recipe](#recipe)
- [Usage](#usage)
  - [SSO](#sso)
- [Troubleshoot](#troubleshoot)
  - [Localhost](#localhost)
  - [Self Connect](#self-connect)
- [Reference](#reference)


[KeyCloak](https://www.keycloak.org) is a popular open-source identity and access management solution.

Basic concepts:
- realm: separated space for managing objects like users, applications, and role
- client: application (web/mobile application/service) which requires authentication
- user: individual who will authenticate against KeyCloak
- role: define permissions and access levels for users


## Recipe
| Command               | Description                              |
|-----------------------|------------------------------------------|
| make start            | launch up container(s) for demo          |
| make fetch_gitlab_pwd | fetch the initial password for GitLab    |
| make end              | stop all relative container(s)           |
| make clean            | clean up container(s), volume(s) created |


## Usage
After containers are up, access
- KeyCloak: https://localhost:8443
- GitLab: https://localhost:43
  - username: root
  - password: can be found at "/etc/gitlab/initial_root_password"

Follow official guides below for more details:
- Docker: https://www.keycloak.org/getting-started/getting-started-docker
  - create realm, user
  - create client to secure application

### SSO
GitLab is deployed to demo Single Sign-On authentication scheme.

To have SSO up and functioning:
- KeyCloak
  1. Create a realm
  2. Create client inside the realm
    1. "General settings"
      - "Client type": OpenID Connect
      - "Client ID": <keycloak_client_id>
    2. "Capability config"
      - turn "Client authentication" on
    3. "Login settings"
      - "Home URL": <http|https>://<gitlab_ip>:<gitlab_port>
      - "Valid redirect URIs": <http|https>://<gitlab_ip>:<gitlab_port>/users/auth/openid_connect/callback
      - "Web origins": <http|https>://<gitlab_ip>:<gitlab_port>
- GitLab
  1. Follow https://docs.gitlab.com/ee/administration/auth/oidc.html for instructions
  2. Set up `GITLAB_OMNIBUS_CONFIG` with KeyCloak parameters just created
    - issuer: "<http|https>://<keycloak_ip>:<keycloak_port>/realms/<name>"
    - client_options
      - identifier: <keycloak_client_id>
      - secret:  <keycloak_client_cred>
  3. enable


## Troubleshoot
All issues related to OpenID Connect would start with
> "Could not authenticate you from OpenIDConnect because ..."

### Localhost
> ... "Failed to open tcp connection to localhost:8443 (connection refused - connect(2)
> for "localhost" port 8443)".

Answer:
Since GitLab and KeyCloak are in different containers, IP or hostname is needed for their connection.
To fix it, ensure the IPs in `GITLAB_OMNIBUS_CONFIG` is correct.

### Self Connect
> ... "Ssl connect returned=1 errno=0 peeraddr=181.3.11.1:8443 state=error: ..."

Problem:
> "... wrong version number"

Answer:
Check which container gets the IP, it's possible that it uses incorrect protocol,
like KeyCloak should use HTTPS instead of HTTP.

Problem:
> "... certificate verify failed (self signed certificate)"

Answer:
Since the self-signed SSL certificate is not trusted by default, GitLab couldn't
have it verified.
There are 3 possible solutions:
- best: use a trusted SSL certificate issued by a Certificate Authority
- moderate: add the self-signed certificate to the trusted certificates in GitLab
- simplest: but not recommended one is to disable SSL verification in GitLab



## Reference
- Running Keycloak in a container: https://www.keycloak.org/server/containers
- Health Check: https://keycloak.org/server/health
- Metrics: https://keycloak.org/server/configuration-metrics
