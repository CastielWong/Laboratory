#!/bin/bash
bash init.sh

airflow celery worker

# monitor for commands to keep container running
exec "$@"
