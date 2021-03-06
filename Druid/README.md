
This directory is to explore Apache Druid, which is an open-sourced timeseries database.

## Preparation
Since the docker-compose needs a directory to map its volume for storage, create a directory called "storage" if not existed.

Note,
> If you experience any processes crashing with a 137 error code you likely don't have enough memory allocated to Docker. 6 GB may be a good place to start.

Which means assigning enough memory in Docker is necessary, and swap may also be needed to increased.

Run `docker-compose up -d` to start up the containers. Access "localhost:8888" to the Druid UI.


## Reference
- Druid run in docker: https://druid.apache.org/docs/latest/tutorials/docker.html
- Official Gitsite: https://github.com/apache/druid
