
1. Run `make run` to launch up the local Airflow
2. Go to "localhost:8080" to start exploration (default username and password is both "airflow")

Stop the local Airflow via `make stop`.

Note that in "docker-compose.yaml", any modified content different from the original will be wrapped inside something like `# -----------------------------customization-------------------------------`.


Useful info to integrate with `paramiko` (https://www.paramiko.org/changelog.html#2.9.0)
```json
{
    "private_key": "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY -----\n",
    "no_host_key_check": "true",
    "allow_host_key_change": "true",
    "disabled_algorithms": {
        "pubkeys": [
            "rsa-sha2-256",
            "rsa-sha2-512"
        ]
    }
}
```


## Reference
- https://airflow.apache.org/docs/apache-airflow/2.7.3/docker-compose.yaml
