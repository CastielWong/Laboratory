#!/usr/bin/env bash

# launch application
docker-compose up -d

CONTAINER_NAME='lab-streamlit'

is_streamlit_up() {
  MSG_CHECK='You can now view your Streamlit app in your browser'

  # check if streamlit is up
  docker logs -n 5 ${CONTAINER_NAME} | \
  grep ${MSG_CHECK} \
  > /dev/null

  returned_value=$?
  echo ${returned_value}
}

echo "Container is up, setting up streamlit"
until [ "$(is_streamlit_up)" -eq 0 ]
do
  sleep 5
  echo "Waiting for streamlit to be ready..."
done

docker logs -n 5 ${CONTAINER_NAME} | head -n 3

open -a "Google Chrome" http://localhost:8501/
