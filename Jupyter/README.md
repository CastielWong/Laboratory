
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


## Virtual Environment

The way to manage virtual environment via `virtualenv` in Jupyter is a bit different.

Firstly, use `virtualenv` to create the virtual environment:

```sh
pip install virtualenv

virtualenv {venv}
```

After `virtualenv` has created the virtual environment, there would be a folder called "{venv}" under current directory.

You can access to the virtual environment in terminal, yet extra efforts need to be done in order to set it as one of the Jupyter Notebook kernal.

```sh
# make sure the virtual environment has been used
source {venv}/bin/activate

# install necessary package "ipykernel"
pip install ipykernel
# install current virtual environment with a name
python -m ipykernel install --name={customized_venv}
```

Then the new kernel "{customized_venv}" should be ready to use by any Jupyter Notebook.

Note that if "ipykernel" is accidentally uninstalled in the virtual environment, such virtual environment would not take effect in the notebook no more.

Whenever the virtual environment is deleted, make sure its corresponding kernel is removed. Otherwise, the orphan kernal would still be listed.

By default, the kernel list would be in "/usr/local/share/jupyter/kernels/".



## Reference

- Jupyter password and Docker: https://stackoverflow.com/questions/48875436/jupyter-password-and-docker
- Using Virtual Environments in Jupyter Notebook and Python: https://janakiev.com/blog/jupyter-virtual-envs/
