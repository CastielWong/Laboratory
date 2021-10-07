
- [Usage](#usage)
- [Specification](#specification)
- [Reference](#reference)


## Usage
Set up the environment via `bash run.sh`. The Jupyter notebook is accessible through "localhost:8888" with password "demo".

Tear down the application via `docker-compose down`.

By default, go to "localhost:8787" to view the Dask dashboard when Dask client is running.

## Specification

There are three ways to utilize scheduler:
```py
# inline
value.compute(scheduler="single-threaded")

# set default (temporary)
with dask.config.set(scheduler="processes"):
    value.compute()

# set default (global)
dask.config.set(scheduler="processes")
```

## Reference
- Getting started with Dask: https://training.talkpython.fm/courses/details/introduction-to-scaling-python-and-pandas-with-dask
- Fundamentals of Dask: https://training.talkpython.fm/courses/details/fundamentals-of-dask-getting-up-to-speed
