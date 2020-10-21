

```sh
# build up image to generate metrics
docker build -t lab-prometheus -f Dockerfile .

docker run --detach --rm --name lab_prometheus \
    -p 8080:8080 -p 80:80 \
    lab-prometheus
```


- https://sysdig.com/blog/prometheus-metrics/
- https://github.com/sysdiglabs/custom-metrics-examples/tree/master/prometheus/python
