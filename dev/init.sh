#!/usr/bin/env bash

# initialize the development environment
PYTHON_VERSION=$1
PYENV_VENV=$2

if [[ -z "${PYTHON_VERSION}" ]]; then
    PYTHON_VERSION="3.8.6"
fi

if [[ -z "${PYENV_VENV}" ]]; then
    PYENV_VENV="dev-demo"
fi

# make sure pyenv is ready
if ! command -v pyenv &> /dev/null; then
    echo "pyenv not found. Start downloading..."

    # install prerequisites (https://github.com/pyenv/pyenv/wiki/Common-build-problems)
    yum install -y \
        @development zlib-devel bzip2 bzip2-devel readline-devel \
        sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel \
        findutils

    # disable SSL verification if issue "SSL certificate problem" is encountered
    default_git_ssl_value=${GIT_SSL_NO_VERIFY}
    export GIT_SSL_NO_VERIFY=true
    curl -k -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    # reset the environment variable back
    export GIT_SSL_NO_VERIFY=${default_git_ssl_value}

    {
        echo -e "\n\n# setup for pyenv"
        echo 'export PATH="${HOME}/.pyenv/bin:${PATH}"'
        echo 'eval "$(pyenv init --path)"'
        echo 'eval "$(pyenv init -)"'
        echo 'eval "$(pyenv virtualenv-init -)"'
    } >> ~/.bashrc

    source "${HOME}/.bashrc"
else
    echo "pyenv has been installed"
fi


# check if the specified venv exists
pyenv versions | grep ${PYENV_VENV}

is_venv_existed=$?

# set up the virtual environment if not
if [ ${is_venv_existed} != 0 ]; then
    pyenv install -v ${PYTHON_VERSION}
    pyenv virtualenv ${PYTHON_VERSION} ${PYENV_VENV}
fi
pyenv activate ${PYENV_VENV}
echo "venv \"${PYENV_VENV}\" is activated"

# set the local venv for auto-enabling
pyenv local ${PYENV_VENV}
echo "venv \"${PYENV_VENV}\" is set up to the project automatically"

# set up pre-commit
pip install --upgrade pip
# install packages for development
pip install -r requirements.txt

pre-commit install
echo "pre-commit is setup"
