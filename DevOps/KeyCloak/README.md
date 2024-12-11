
This is the demo project for KeyCloak.

- [Recipe](#recipe)
- [Usage](#usage)
- [Development](#development)
  - [Configuration](#configuration)
  - [SSL Certificate](#ssl-certificate)
    - [Concept](#concept)
    - [Cryptographic File](#cryptographic-file)
    - [Generation](#generation)
    - [Certificate Check](#certificate-check)
  - [SSO](#sso)
- [Troubleshoot - GitLab](#troubleshoot---gitlab)
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
| make gen_cert         | generate self-signed SSL certificate     |
| make end              | stop all relative container(s)           |
| make destroy          | destroy custom built images              |
| make clean            | clean up container(s), volume(s) created |


## Usage
After containers are up, access
- KeyCloak:
  - https://keycloak.lab:8443
  - https://localhost:8443
  - not working: https://[<host_name>|localhost]
- GitLab: https://localhost:443
  - username: root
  - password: can be found at "/etc/gitlab/initial_root_password"

Follow official guides below for more details:
- Docker: https://www.keycloak.org/getting-started/getting-started-docker
  - create realm, user
  - create client to secure application


## Development
"kc.sh" is under "${HOME}/bin".

Remember to add record in like "127.0.0.1 keycloak.lab" in "/etc/hosts" to access
KeyCloak via common name ("https://keycloak.lab").

When HTTPS mode is enabled and the host name set, it must access via the hostname
but not "https://localhost:8443".
Otherwise, the KeyCloak would be hold with “Loading to Admin UI” page without further
responding when try to access "Administration Console".

### Configuration
According to KeyCloak's [configuration](https://www.keycloak.org/server/configuration),
the priority on configuration loading is:
Command-line Parameters
-> Environment Variables
-> Configuration File (default "${HOME}/conf/keycloak.conf")
-> User-Created Java KeyStore File

### SSL Certificate
SSL (Secure Sockets Layer) and TLS (Transport Layer Security) are often used
interchangeably.

To check what info the certificate includes, run
`openssl x509 -in ./ssl/server.crt -text -noout`

Though there is CN (Common Name) defined in the certificate, it doesn't necessarily
the same as the configuration.

#### Concept
An SSL certificate is a digital certificate that authenticate the identity
of a website and enables an encrypted connection.

How SSL certificate works:
- Public Key Infrastructure: SSL certificates rely on PKI for encryption and decryption
- Encryption: When a browser connects to a secure server, the server sends its SSL
certificate, the browser verifies the certificate and uses the public key to establish
a secure session
- Handshake Process: The SSL/TLS handshake is the process that initiates a secure
session, which involves the exchange of keys and the establishment of encryption methods

#### Cryptographic File
A ".pem" file is a file format that stands for "Privacy Enhanced Mail", which is used
to store and transmit cryptographic keys/certificates and typically contain data that
is encoded in Base64, including SSL/TLS for securing communications over the internet.

A ".pem" file includes specific header and footer lines that indicate the type of data
contained within, such as:
- header
  - `-----BEGIN CERTIFICATE-----`
  - `-----BEGIN PRIVATE KEY-----`
  - `-----BEGIN PUBLIC KEY-----`
  - `-----BEGIN RSA PRIVATE KEY-----`
- footer
  - `-----END CERTIFICATE-----`
  - `-----END PRIVATE KEY-----`
  - `-----END PUBLIC KEY-----`
  - `-----END RSA PRIVATE KEY-----`

".crt" file
- is a certificate file that typically contains and SSL/TLS certificate:
- can be in PEM (base64 encoded) or DER (binary) format
- can contain a public key, the certificate holder info, the CA, and validity period

".cer" file
- is a certificate, which is similar to a ".crt" file
- it is commonly used in Windows
- may contain a single certificate or a chian of certificates

".key" file
- typically contains a private key associated with an SSL/TLS certificate:
- usually in PEM format
- often paired with a ".crt" or ".cer" file for complete SSL/TLS certificate configuration

#### Generation
Generate self-signed certificate for KeyCloak and GitLab to use HTTPS via:
`source generate_ssl_cert.sh`

SSL/TLS certificates are essential for establishing secure connections over HTTPS.

#### Certificate Check
When a client (such as a web browser or another service) connects to a server using
HTTPS, it checks the certificate presented by the server.
One of the checks it performs is to verify that the hostname in the URL matches the
CN (or Subject Alternative Name, SAN) in the certificate.
If there is a mismatch, the client will typically reject the connection and display
a warning or error message.

Using a certificate with a matching CN helps prevent man-in-the-middle (MITM) attacks,
where an attacker could intercept the connection and present a different certificate.
By ensuring that the CN matches the expected hostname, it helps ensuring that clients
are communicating with the intended server.


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
  3.


## Troubleshoot - GitLab
All issues related to OpenID Connect would start with
> "Could not authenticate you from OpenIDConnect because ..."

### Localhost
> ... "Failed to open tcp connection to localhost:8443 (connection refused - connect(2)
> for "localhost" port 8443)".

Answer:
Since GitLab and KeyCloak are in different containers, IP or hostname is needed for their connection.
To fix it, ensure the IPs in `GITLAB_OMNIBUS_CONFIG` is correct.

### Self Connect
The common prefix of each error message:
> ... "Ssl connect returned=1 errno=0 peeraddr=181.3.11.1:8443 state=error: ..."

-------------------------------------------------------------------------------
Problem:
> "... wrong version number"

Answer:
Check which container gets the IP, it's possible that it uses incorrect protocol,
like KeyCloak should use HTTPS instead of HTTP.

-------------------------------------------------------------------------------
Problem:
> "... certificate verify failed (self signed certificate)"

Answer:
Since the self-signed SSL certificate is not trusted by default, GitLab couldn't
have it verified.
There are 3 possible solutions:
- best: use a trusted SSL certificate issued by a Certificate Authority
- moderate: add the self-signed certificate to the trusted certificates in GitLab
- simplest: but not recommended one is to disable SSL verification in GitLab

Ensure the "/etc/gitlab/trusted-certs/<name>.crt" certificate exists.

-------------------------------------------------------------------------------
Problem:
> "Hostname "<ip>/<host_name>" does not match the server certificate".

Answer:
Update the hostname at `gitlab_rails["omniauth_providers"]` -> `args` -> "issuer".

-------------------------------------------------------------------------------
Problem:
> "Connection refused - connection refused - connect(2) for '<host>' port <port> (<host>:<port>)"

Answer:
It's possibly because the GitLab container failed to resolve KeyCloak container's
host name.
Like resolving "keycloak.lab" to "127.0.0.1", which causes loopback address and
resolve that to the GitLab container itself.

Other than the host name like "keycloak.lab", use "keycloak" the service name set
in the compose file.

Run commands in GitLab container to see if it resolves correctly:
- `ping <service_name>`
- `curl -k https://<service_name>:8443/realms/demo`

-------------------------------------------------------------------------------
Problem:
> "Hostname '<host_name>' does not match the server certificate"

Answer:
Check if the common name specified in the SSL certificate matched the host name.
Update the SSL certificate with the matched host name.

-------------------------------------------------------------------------------
Problem:
> "Not found"

Answer:
Ensure the Realm is created

-------------------------------------------------------------------------------
Problem:
> "Issuer mismatch"

Answer:


## Reference
- Running Keycloak in a container: https://www.keycloak.org/server/containers
- Health Check: https://keycloak.org/server/health
- Metrics: https://keycloak.org/server/configuration-metrics
