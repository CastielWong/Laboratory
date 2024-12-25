
ENV_FILE := /home/.env

gen_token:
	bash script/generate_access_token.sh

run_native:
	python run_with_pyiceberg.py

run_spark: gen_token
	export $$(grep -v '^#' ${ENV_FILE} | xargs) && python run_with_pyspark.py
