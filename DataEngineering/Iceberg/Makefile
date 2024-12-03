
CONTAINER_NAME := lab-iceberg-spark

start:
	docker-compose up -d

run:
	docker exec -it -w /home/workspace $(CONTAINER_NAME) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
	# docker volume rm warehouse notebooks
	rm -rf warehouse/ notebooks/ workspace/__pycache__/
