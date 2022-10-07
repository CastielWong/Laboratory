#!/usr/bin/env bash

# initialize the development environment
PYTHON_VERSION=$1
PYENV_VENV=$2
IS_JUPYTER=$3

if [[ -z "${PYTHON_VERSION}" ]]; then
    PYTHON_VERSION="3.8.6"
fi

if [[ -z "${PYENV_VENV}" ]]; then
    PYENV_VENV="laboratory"
fi

if [[ -z "${IS_JUPYTER}" ]]; then
    IS_JUPYTER=false
fi

# make sure pyenv is ready
if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found. Start downloading..."

    pyenv_installer="https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer"

    # install prerequisites (https://github.com/pyenv/pyenv/wiki/Common-build-problems)
    yum install -y \
        @development zlib-devel bzip2 bzip2-devel readline-devel \
        sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel \
        findutils

    # disable SSL verification if issue "SSL certificate problem" is encountered
    default_git_ssl_value=${GIT_SSL_NO_VERIFY}
    export GIT_SSL_NO_VERIFY=true
    curl -k -L ${pyenv_installer} | bash
    # reset the environment variable back
    export GIT_SSL_NO_VERIFY=${default_git_ssl_value}

    {
        echo -e "\n\n# Customization"
        echo "export PS1=\"[\t \w]\$ \""
        echo -e "\n# setup for pyenv"
        echo "export PYENV_ROOT=${HOME}/.pyenv"
        echo 'export PATH="${PYENV_ROOT}/bin:${PATH}"'
        echo 'eval "$(pyenv init --path)"'
        echo 'eval "$(pyenv init -)"'
        echo 'eval "$(pyenv virtualenv-init -)"'
    } >> ~/.bashrc

    source "${HOME}/.bashrc"
fi

echo "pyenv has been installed."


# check if the specified version exists
pyenv versions | grep ${PYTHON_VERSION} &> /dev/null
if [ $? != 0 ]; then
    echo "Installing version requested..."
    pyenv install -v ${PYTHON_VERSION}
fi


# check if the specified venv exists
pyenv versions | grep ${PYENV_VENV} &> /dev/null
if [ $? != 0 ]; then
    # set up the virtual environment if not existed
    pyenv virtualenv ${PYTHON_VERSION} ${PYENV_VENV}
else
    # check if the version requested matched
    pyenv versions | grep ${PYTHON_VERSION}/envs/${PYENV_VENV} &> /dev/null
    if [ $? != 0 ]; then
        echo "Existing venv \"${PYENV_VENV}\" is not with version ${PYTHON_VERSION}."
        echo "Run 'pyenv versions' first to confirm it's expected."
        exit 1
    fi
fi

pyenv activate ${PYENV_VENV}
echo "venv \"${PYENV_VENV}\" is activated."

# set the local venv for auto-enabling
pyenv local ${PYENV_VENV}
echo "venv \"${PYENV_VENV}\" is set up to the project automatically."

# set up pre-commit
pip install --upgrade pip

if [[ -f "requirements.txt" ]]; then
    echo "Installing packages from \"requirements.txt\"..."
    pip install -r requirements.txt &> /dev/null
fi

if ${IS_JUPYTER}; then
    echo "Installing package used to set Jupyter kernel...."
    pip install ipykernel
    # jupyter kernelspec list

    # set venv to Jupyter kernel
    python -m ipykernel install --name=${PYENV_VENV} --user

    # pyenv activate ${PYENV_VENV}
fi

git status &> /dev/null
if [ $? -eq 0 ] ; then
    # set up pre-commit if it's a git repo
    pre-commit install &> null
    if [ $? == 0 ]; then
        echo "pre-commit is setup"
    fi
fi
