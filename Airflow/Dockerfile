FROM apache/airflow:2.0.0-python3.8

USER root

ARG AIRFLOW_USER_HOME=/home/airflow
ARG AIRFLOW_HOME=/opt/airflow

ARG uid=airflow
ARG gid=root


# install software package needed
RUN apt-get update \
  && apt-get install -y vim wget
# remove package list
RUN rm -rf /var/lib/apt/lists/*

COPY --chown=${uid}:${gid} ./entrypoint.sh ${AIRFLOW_HOME}/
RUN chmod 755 ${AIRFLOW_HOME}/entrypoint.sh

USER ${uid}

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["./entrypoint.sh"]
