FROM tabulario/spark-iceberg:3.5.1_1.5.0
# FROM tabulario/spark-iceberg:3.3.1_1.1.0

COPY image/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# install MinIO Client
ARG HOME=/root
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
    --create-dirs \
    -o $HOME/minio-binaries/mc

RUN chmod +x $HOME/minio-binaries/mc

ENV PATH=$PATH:$HOME/minio-binaries/
