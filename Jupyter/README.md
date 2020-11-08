
This section is used to easily and quickly provision a Jupyter local environment.

Based on requirements, select the proper version of Jupyter needed from https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html.

Core stacks available are:
- [Base Notebook](https://hub.docker.com/r/jupyter/base-notebook/tags/)
- [Minimal Notebook](https://hub.docker.com/r/jupyter/minimal-notebook/tags/)
- [R Notebook](https://hub.docker.com/r/jupyter/r-notebook/tags/)
- [Scipy Notebook](https://hub.docker.com/r/jupyter/scipy-notebook/tags/)
- [Tensorflow Notebook](https://hub.docker.com/r/jupyter/tensorflow-notebook/tags/)
- [Data Science Notebook](https://hub.docker.com/r/jupyter/datascience-notebook/tags/)
- [PySpark Notebook](https://hub.docker.com/r/jupyter/pyspark-notebook/tags/)
- [All Spark Notebook](https://hub.docker.com/r/jupyter/all-spark-notebook/tags/)


## Running

Run `docker-compose up -d` to start the Jupyter Notebook in detached mode.

By default, token is set, access "http://localhost:8888/?token=demo" to use Jupyter directly.

If the token is not set and random token is preferred, then run `docker-compose logs | sed -n '/token=/p' | head -1 | cut -d '=' -f 2` to extract the generated token out. With the token retrieved, access "http://localhost:8888/" to start the notebook.


## Reference

- Jupyter password and Docker: https://stackoverflow.com/questions/48875436/jupyter-password-and-docker
