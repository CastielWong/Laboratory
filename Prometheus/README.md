

```sh
# build up image to generate metrics
docker build -t lab-prometheus -f Dockerfile .

docker run --detach --rm --name lab_prometheus \
    -p 8080:8080 -p 80:80 \
    lab-prometheus

# run the prometheus
docker run --rm -p 9090:9090 \
    -v $(pwd)/config/:/etc/prometheus/ \
    -it prom/prometheus
```

Run `ifconfig | grep -i mask` to retrieve private IP address. Then place it to the "targets" of "demoing" job in "prometheus.yml" inside directroty "config".

Open "localhost:9090" via browser and check `avg(rate(showing_counter[5m])) by (job, service)` to verify it's successfully connected to the metrics genetator. Make sure the If there is no datapoints at all.


- https://sysdig.com/blog/prometheus-metrics/
- https://github.com/sysdiglabs/custom-metrics-examples/tree/master/prometheus/python
- https://www.scalyr.com/blog/prometheus-tutorial-detailed-guide-to-getting-started/
