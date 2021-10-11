
- [Usage](#usage)
- [Specification](#specification)
- [Limitation](#limitation)
  - [DataFrame](#dataframe)
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


## Limitation

### DataFrame
> Dask DataFrame API does not implement the complete pandas interface because some pandas operations are not suited for a parallel and distributed environment.
>
> Dask DataFrames consist of multiple pandas DataFrames, each of which has it's index starting from zero. Some operations like indexing (set_index, reset_index) may need the data to be sorted, which requires a lot of time-consuming shuffling of data. These operations are slower in Dask. Hence, presorting the index and making logical partitions are good practices.



## Reference
- Getting started with Dask: https://training.talkpython.fm/courses/details/introduction-to-scaling-python-and-pandas-with-dask
- Fundamentals of Dask: https://training.talkpython.fm/courses/details/fundamentals-of-dask-getting-up-to-speed
