

The "docker-compose.yaml" is from https://github.com/coder/coder/blob/main/docker-compose.yaml.

Access to Coder via "0.0.0.0:7080" in browser.

To enable the Coder container to utilize Docker in the host machine, it's needed to
enable the user in Coder container to own write permission to Docker's socket.

By default, the uid of non-root user "coder" inside Coder container is "1000", and gid
of root user "root" is "0".
So we set `user: "1000:0"` in the compose file to enable the container to call Docker.


## Reference
- Install Coder with Docker: https://coder.com/docs/install/docker
