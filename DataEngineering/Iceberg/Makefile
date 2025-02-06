.PHONY: run clean

CONTAINER_NAME := lab-iceberg-spark

start:
	docker-compose up -d

run:
	docker exec -it --workdir /home/workspace $(CONTAINER_NAME) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
	# docker volume rm warehouse notebooks
	rm -rf notebooks/ warehouse_fs/ warehouse_s3/
	rm -rf workspace/__pycache__/ \
		workspace/metastore_db/ \
		workspace/spark-warehouse \
		workspace/derby.log
