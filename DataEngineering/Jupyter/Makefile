.PHONY: run clean

CONTAINER_NAME := lab-jupyter

start:
	docker-compose up -d

run:
	docker exec -it --workdir /home/jovyan/work $(CONTAINER_NAME) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
