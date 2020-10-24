
- [Running](#running)
    - [Shortcut](#shortcut)
    - [Client](#client)
    - [Server](#server)
- [Reference](#reference)


This project is used to explore how Prometheus is collecting metrics.

## Running

To supply Prometheus server with metrics, a metric generator is needed. The _Dockerfile_ is used to create the Metrics Generator image, which is implemented in Python with Flask. Scripts below is to create the image, and then run the corresponding container.

```sh
# build up image to generate metrics
docker build -t lab-prometheus-metrics-generator -f Dockerfile .

docker run --detach --rm --name metrics-metric_generator \
    -p 8080:8080 -p 80:80 \
    lab-prometheus-metrics-generator
```

Run `ifconfig | grep -i mask` to retrieve private IP address. Then place it to the "targets" of "demoing" job in "prometheus.yml" inside directroty "config". The "config/prometheus.yml" file is the customized configuration of Prometheus server. Then retrieve image "prom/prometheus" from Docker Hub and create the container:

```sh
# run the prometheus
docker run --detach --rm -p 9090:9090 \
    -v $(pwd)/config/:/etc/prometheus/ \
    -it prom/prometheus:v2.22.0
```

### Shortcut

Avoiding unnecessary hassles, after customizing "Dockerfile", "main.py" and "config/prometheus.yml", it's highly suggested to manage containers with docker-compose directly. Simply run `docker-compose up -d` to run containers for the demo.

### Client

Go to "localhost:8080" via browser, the metrics should be generated and ready to scrape/collect.

### Server

Open "localhost:9090" via browser and execute following expressions to verify the Prometheus server is successfully connected to the metrics genetator.
- avg(rate(showing_counter[5m])) by (job, service)
- showing_gauge_label
- avg(rate(showing_gauge_label[5m])) by (job, service, tagging, version)


## Reference

- Prometheus metrics / OpenMetrics code instrumentation: https://sysdig.com/blog/prometheus-metrics/
- Prometheys Tutorial - A Detailed Guid to Getting Started: https://www.scalyr.com/blog/prometheus-tutorial-detailed-guide-to-getting-started/
