
- [Running](#running)
- [Virtual Environment](#virtual-environment)
- [Reference](#reference)


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

Firstly, run `python -m venv {venv}` to create the virtual environment. After the virtual environment is created, there would be a folder called "{venv}" under current directory.

You can access to the virtual environment in terminal, yet extra efforts need to be done in order to set it as one of the Jupyter Notebook kernal.

```sh
# install and update packing packages
pip install --upgrade pip wheel

# activate virtual environment
source {venv}/bin/activate

# install necessary package "ipykernel"
pip install ipykernel
# install current virtual environment with a name
# make sure the virtual environment is activated
# otherwise it wouldn't be recognize as a kernel
python -m ipykernel install --name={customized_venv}
```

Then the new kernel "{customized_venv}" should be ready to use by any Jupyter Notebook.

Note that if "ipykernel" is accidentally uninstalled in the virtual environment, such virtual environment would not take effect in the notebook no more.

Whenever the virtual environment is deleted, make sure its corresponding kernel is removed. Otherwise, the orphan kernal would still be listed. By default, the kernel list would be in "/usr/local/share/jupyter/kernels/".

Or run `jupyter kernelspec uninstall {customized_venv}` to uninstall the unneeded kernel.
Run `jupyter kernelspec list` to confirm all listed kernel are expected.



## Reference

- Jupyter password and Docker: https://stackoverflow.com/questions/48875436/jupyter-password-and-docker
- Using Virtual Environments in Jupyter Notebook and Python: https://janakiev.com/blog/jupyter-virtual-envs/
- Top 10 Magic Commands in Python to Boost your Productivity: https://towardsdatascience.com/top-10-magic-commands-in-python-to-boost-your-productivity-1acac061c7a9
