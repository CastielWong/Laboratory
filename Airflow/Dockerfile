FROM apache/airflow:2.0.0-python3.8

USER root

ARG AIRFLOW_USER_HOME=/home/airflow
ARG AIRFLOW_HOME=/opt/airflow
ARG DOCKERIZE_VERSION=v0.6.1

ARG uid=airflow
ARG gid=root


# install software package needed
RUN apt-get update \
  && apt-get install -y vim wget
# remove package list
RUN rm -rf /var/lib/apt/lists/*

# install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && rm dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

COPY --chown=${uid}:${gid} ./entrypoint.sh ${AIRFLOW_HOME}/
RUN chmod 755 ${AIRFLOW_HOME}/entrypoint.sh

USER ${uid}

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["./entrypoint.sh"]
