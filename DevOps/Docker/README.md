
- [Mac](#mac)
  - [Docker Machine](#docker-machine)
- [Reference](#reference)


This demonstration is used to show the basic usage of Docker and Docker Compose,
as well as memo or investigation related.

- Run `docker-compose up -d` to start the exploration
- Run `docker-compose down` to shut down running container

"init.sh" is used to set up Python virtual environment for development.

## Mac
Though it's recommended to install Docker via Docker Desktop, having its components installed via Homebrew with VirtualBox is another way `brew install`:
- daemon: `docker-machine`
- client: `docker docker-compose`

Note that:
- subnet may not work with Docker Desktop
  - access container application through "{subnet_ip}:{port}" doesn't work
- volume mapping has restriction via VirtualBox
  - > By default the /Users, /Volume, /private, /tmp and /var/folders directory are shared. If your project is outside this directory then it must be added to the list, otherwise you may get Mounts denied or cannot start service errors at runtime.

### Docker Machine
To kick off "docker-machine", "virtualbox" is required also: `docker-machine create --driver virtualbox default`, or `docker-machine create -d virtualbox --virtualbox-hostonly-cidr "192.168.63.1/24" default` in case it's [outside the range](https://stackoverflow.com/questions/69805077/cannot-start-docker-daemon-at-macbook/70373434#70373434). Detailed steps can be found in [reference](#reference).

1. Start the daemon
   - run `docker-machine create --driver virtualbox default` if works
   - run `docker-machine create -d virtualbox --virtualbox-hostonly-cidr "192.168.63.1/24" default` if exception "Error setting up host only network on machine start" thrown
2. Start the host `docker-machine start default` if not up
3. Set up environment for docker usage `eval $(docker-machine env default)`



https://stackoverflow.com/questions/22111060/what-is-the-difference-between-expose-and-publish-in-docker/47594352#47594352


## Reference
- A complete one-by-one guide to install Docker on your Mac OS using Homebrew: https://medium.com/crowdbotics/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3
- Cannot start Docker daemon at MacBook: https://stackoverflow.com/questions/69805077/cannot-start-docker-daemon-at-macbook/70373434#70373434
- File sharing: https://docs.docker.com/desktop/settings/mac/
- Cannot see mounted Volumes on docker host/docker-machine: https://stackoverflow.com/questions/33575351/docker-machine-on-mac-cannot-see-mounted-volumes-on-docker-host-docker-machine
