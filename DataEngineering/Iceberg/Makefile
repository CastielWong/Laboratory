
CONTAINER_HIVE := demo-iceberg
VOLUME := warehouse

start:
	docker-compose up -d

run:
	docker exec -it -w /home/workspace spark-iceberg bash

stop:
	docker-compose down

clean:
	echo y | docker system prune
	# docker volume rm $(VOLUME)
