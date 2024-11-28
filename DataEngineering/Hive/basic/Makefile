
CONTAINER_HIVE := lab-hive-basic
# VOLUME := hive_warehouse
DIR_WAREHOUSE := warehouse

start:
	docker-compose up -d

	# wait for a little while for the Hive to start
	sleep 30

run:
	docker exec -it $(CONTAINER_HIVE) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
	rm -rf $(DIR_WAREHOUSE)
	# docker volume rm $(VOLUME)
