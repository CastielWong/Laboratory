
CONTAINER_HIVE := lab-hive-metastore
HIVE_URL = jdbc:hive2://localhost:10000/
VOLUME := lab_hive_minio

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_HIVE) spark-shell --conf spark.sql.warehouse.dr=s3a://checking/

end:
	docker-compose down

clean: end
	echo y | docker system prune
	rm -rf $(VOLUME)
