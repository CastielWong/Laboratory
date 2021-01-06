
- [Git](#git)
  - [Tagging](#tagging)
  - [GitFlow](#gitflow)
- [Setup](#setup)
  - [pyenv](#pyenv)
  - [pre-commit](#pre-commit)
- [Docker](#docker)
- [Submodule](#submodule)
- [Reference](#reference)


This repo is for experiments of any greenfield technologies or some quick catch-ups.

## Git

To push this repo from local to Github:

```sh
git remote add origin https://github.com/CastielWong/Laboratory.git
git push -u origin master
```

### Tagging

Common commands for tagging:
- `git tag`: check existing tags
- `git tag -a lastest-{section} -m "{tag message}" {commit}`: create an annotated tag for the specified commit with tagging message
- `git tag -d {tag}`: delete a tag
- `git push origin --tags`: synchronize all tags at the remote repo
- `git push origin --delete {tag}`: delete a tag at remote side

### GitFlow

Gitflow is a good practice used to develop and maintain the git workflow:
- `git flow feature start {branch}`: create a new feature branch, which is branched from "develop"
- `git flow feature finish {branch}`: finish a branch by merging it back to develop and remove the feature branch


## Setup

### pyenv

Since most of the scripts involved would be in Python, to make the environment clean and easy to manage, [pyenv](https://github.com/pyenv/pyenv) is used to manage Python version and libraries.

For Mac user, it's suggested to install [Homebrew](https://brew.sh/) to get "pyenv":

```sh
# update Homebrew
brew update
brew install pyenv
# install the needed library for pyenv
brew install pyenv-virtualenv

# verify pyenv has been installed
brew list
```

For Linux user, follow steps below for the installation:

```sh
# install pyenv (https://github.com/pyenv/pyenv#installation)
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc

# install pyenv-virtualenv (https://github.com/pyenv/pyenv-virtualenv#installing-as-a-pyenv-plugin)
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
```

Note, if encountering warnings like "MIssing the GNU readline lib" or "Missing the SQLite3 lib", fix them by running:
```sh
sudo yum install readline-devel
sudo yum install sqlite-devel
```

Then apply `pyenv` to create and use the virtual environment. Below is those commonly used commands:

```sh
# install python with specified version, run `pyenv install --list` to check what version is available
pyenv install {version}
# check python version installed
pyenv versions

# create a virtual environment in name {venv} with {version}
pyenv virtualenv -p python{3.x} {version} {venv}
# activate to the virtual environment
pyenv activate {version}
# enable automatic virtual environment switching
pyenv local {venv}

# deactivate current virtual environment
pyenv deactivate
```

### pre-commit

It's a good practice to have [pre-commit](https://pre-commit.com/) in git repository for the purpose of code linting and formatting.
Then follow steps below to activate "pyenv" and setup "pre-commit":

Install pre-commit and regulate the format of commit message:

```sh
pip install pre-commit
# check all files with pre-commit
pre-commit run --all-files

# set up pre-commit so that it would be triggered automatically whenever make an commit
pre-commit install

# set up the commit message check
cp commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```


## Docker

Most of labs are done in Docker. For convenience, common Docker commands are listed below:

- `docker run --rm -it {image} bash`: start a container and access it via bash, which would be removed when it's stopped
- `docker rm $(docker ps -a -q -f status=exited)`: remove all containers with status existed
- `docker cp {container_id}:{dir_source}/{file} {dir_target}/{file}`: copy files from container to local directory
- `docker-compose up --detached`: start containers via `docker-compose`, for whose configuration is usually set in "docker-compose.yml"
- `docker-compose down`: stop and remove all containers `docker-compose` initiated


## Submodule

Sometimes it's better to reference codes for exploration, so submodule is a good solution for that purpose.

To add an extrenal git repo, run:
`git submodule add {repo} {directory}`

To update submodules, run:
`git submodule update --init`

To remove an added module, follows:
```sh
# unregister the submodule with its path
git submodule deinit -f -- {module_path}
# remove meta data related to the submodule
rm -rf .git/modules/{module_path}
# remove the module from project
git rm -f {module_path}
```


## Reference
- Compose file version 3 reference: https://docs.docker.com/compose/compose-file
- Semantic Versioning: https://semver.org/
- Git Basics - Tagging: https://git-scm.com/book/en/v2/Git-Basics-Tagging
- Giflow Workflow: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
