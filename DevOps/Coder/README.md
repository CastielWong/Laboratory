

The "docker-compose.yaml" is from https://github.com/coder/coder/blob/main/docker-compose.yaml.

Access to Coder via "0.0.0.0:7080" in browser.


## Configuration
To enable the Coder container to utilize Docker in the host machine, it's needed to
enable the user in Coder container to own write permission to Docker's socket.

By default, the uid of non-root user "coder" inside Coder container is "1000", and gid
of root user "root" is "0".
So we set `user: "1000:0"` in the compose file to enable the container to call Docker.

For `CODER_ACCESS_URL`, it should be set to `http://<CODER_CONTAINER>:7080`.
To enable Coder's Docker Workspace to be able to fetch configuration, plugins, packages
etc. from Coder, we need to ensure the workspace (container) created is in the same
network as the Coder container.

When Coder is up and running, if the Docker template is created from Coder's official
starter template, remember to include the network name in the template to make sure
its workspace is created within the same network as Coder's one:
```tf
resource "docker_container" "workspace" {
    ...

    network_mode = "<NETWORK_NAME>"
}
```


## Maintenance
Even though `make clean` would tear down coder's relevant containers created, it
wouldn't remove those workspace containers.
Do not forget to delete workspaces before destroying the Coder container.


## Reference
- Install Coder with Docker: https://coder.com/docs/install/docker
