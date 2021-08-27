#!/bin/bash

DOCKER_COMPOSE_SERVICE_GRAFNA=grafana
CONTAINER_GRAFNA=demo-grafana

docker-compose up -d

docker exec -it ${CONTAINER_GRAFNA} /configuration/init.sh

# restart Grafana to enable plugins
docker-compose restart ${DOCKER_COMPOSE_SERVICE_GRAFNA}
