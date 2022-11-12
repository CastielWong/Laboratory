
- [Development](#development)
- [Setup](#setup)
  - [Virtual Environment](#virtual-environment)
    - [Mac](#mac)
    - [Linux](#linux)
  - [Code Quality](#code-quality)
- [Git](#git)
  - [Permission](#permission)
  - [Branching Model](#branching-model)
    - [GitFlow](#gitflow)
    - [Trunk Based](#trunk-based)
  - [Tagging](#tagging)
  - [Submodule](#submodule)
  - [Revert](#revert)
- [Docker](#docker)
- [Reference](#reference)


This repo is for experiments of any greenfield technologies or some quick catch-ups.

## Development

After complete a feature branch (after merged), run `bash ./dev/tag_feature.sh '{name}' '{tag description}'` to tag current commit then synchronize for remote.



## Setup

### Virtual Environment
Since most of the scripts involved would be in Python, to make the environment clean and easy to manage, [pyenv](https://github.com/pyenv/pyenv) is used to manage Python version and libraries.

#### Mac
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

Then copy commands below to current user's ".bashrc", ".bash_profile" or other related one for the shell to get it activated:
```sh
# initialize pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
if [ -n "$PS1" -a -n "$BASH_VERSION" ]; then source ~/.bashrc; fi
eval "$(pyenv init -)"

# initialize virtualenv
eval "$(pyenv virtualenv-init -)"
```

#### Linux
For Linux user, follow steps below for the installation:
```sh
# install pyenv
# either via https://github.com/pyenv/pyenv#installation
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
# or via https://github.com/pyenv/pyenv-installer
curl https://pyenv.run | bash

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc

# install pyenv-virtualenv (https://github.com/pyenv/pyenv-virtualenv#installing-as-a-pyenv-plugin)
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
```

For RedHat OS, if encountering warnings like "Missing the GNU readline lib" or "Missing the SQLite3 lib", fix them by running:
```sh
sudo yum install readline-devel
sudo yum install sqlite-devel
```

For Ubuntu OS, some packages needed before using `pyenv` for the reason that Python installation required:
```sh
apt-get install build-essential \
    zlib1g-dev libffi-dev libssl-dev libbz2-dev \
    libreadline-dev libsqlite3-dev liblzma-dev \
    -y
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

### Code Quality
THe code quality (at least for Python) is mainly maintained by `pre-commit`:
- Formatter:
  - `black`: format Python code without compromise
  - `isort`: format imports by customized sorting
- Stylistic:
  - `pylint`: check for errors and code smells, and tries to enforce coding standard
  - `pycodestyle`: check against style conventions in PEP8, used by `flake8`
  - `pydocstyle`: check compliance with Python docstring conventions
- Logical:
  - `mypy`: check for optionally-enforced static types
  - `pyflakes`: analyze programs and detect various errors, used by `flake8`
  - `bandit`: analyze code to find common security issues
- Analytical:
  - `mccabe`: check McCabe complexity, used by `flake8`
  - `radon`: analyze code for various metrics

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
cp ./dev/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```



## Git
To set the default initialized branch to "main", run `git config --global init.defaultBranch main`.

To push this repo from local to Github:
```sh
git remote add origin https://github.com/CastielWong/Laboratory.git
git push -u origin main
```

There are several ways to rename the "master" branch to "main" locally. Remember to rename it in the remote repo before take any action below.

1. Clone the project totally (Recommended if nothing stashed).

2. Rename then reset origin (Recommended if local repo is desired to keep):
```sh
# rename master branch
git branch -m master main
# either `git fetch` or remove the "main" branch in ".git/config"
git fetch --all --prune
# reset origin
git push --set-upstream origin main
```

3. Fetch change from remote (Not recommended):
```sh
git branch -m master main
# ensure the remote branch is renamed already
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```


### Permission
```sh
# check configuration
git config --list --show-origin

# start the authentication agent with Bourne shell commands generated on "stdout"
eval `ssh-agent -s`

# check if any identity is set
ssh-add -l
# add the identity/credential
ssh-add ~/.ssh/{id}

# verify the identity is working
ssh-add -l
```


### Branching Model
There are different approaches to branch a repo. It's more about the preference.

#### GitFlow
[Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) is considered to be a good practice used to develop and maintain the git workflow:
- `git flow feature start {branch}`: create a new feature branch, which is branched from "develop"
- `git flow feature finish {branch}`: finish a branch by merging it back to develop and remove the feature branch

#### Trunk Based
[Trunk Based Development](https://trunkbaseddevelopment.com/) is another good practice for collaboration.
> A source-control branching model, where developers collaborate on code in a single branch called "trunk", resist any pressure to create other long-lived development branches by employing documented techniques.


### Tagging
Common commands for tagging:
- `git tag`: check existing tags
- `git tag -a latest-{section} -m "{tag message}" {commit}`: create an annotated tag for the specified commit with tagging message
- `git tag -d {tag}`: delete a tag
- `git push origin --tags`: synchronize all tags at the remote repo
- `git push origin --delete {tag}`: delete a tag at remote side


### Submodule
Sometimes it's better to refer codes for exploration, so submodule is a good solution for that purpose.

To add an external git repo, run:
`git submodule add {repo} {directory}`

To update submodules, run:
`git submodule update --init --recursive`

If previous command to update failed, try `git submodule foreach git pull` instead.


To remove an added module, follow:
```sh
# unregister the submodule with its path
git submodule deinit -f -- {module_path}
# remove meta data related to the submodule
rm -rf .git/modules/{module_path}
# remove the module from project
git rm -f {module_path}
```

### Revert
To revert a file to previous commit, run:
```sh
# find out previous commits involved such file changed
git rev-list -n <n> HEAD <file>
# revert the file to the specified commit softly
git reset <commit> <file>
```


## Docker
Most of labs are done in Docker. For convenience, common Docker commands are listed below:
- `docker run --rm -it {image} bash`: start a container and access it via bash, which would be removed when it's stopped
- `docker rm $(docker ps -a -q -f status=exited)`: remove all containers with status existed
- `docker cp {container_id}:{dir_source}/{file} {dir_target}/{file}`: copy files from container to local directory
- `docker-compose up --detached`: start containers via `docker-compose`, for whose configuration is usually set in "docker-compose.yml"
- `docker-compose down`: stop and remove all containers `docker-compose` initiated



## Reference
- Compose file version 3 reference: https://docs.docker.com/compose/compose-file
- Semantic Versioning: https://semver.org/
- Conventional Commits: https://www.conventionalcommits.org/en/v1.0.0/
- Git Basics - Tagging: https://git-scm.com/book/en/v2/Git-Basics-Tagging
- Gitflow Workflow: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
- Python Code Quality: https://realpython.com/python-code-quality/
- Playbook Deployment: https://wa.aws.amazon.com/wellarchitected/2020-07-02T19-33-23/wat.concept.playbook.en.html
- Play with Docker Classroom: https://training.play-with-docker.com/
- Bitbucket - Permission denied (publickey): https://confluence.atlassian.com/bbkb/permission-denied-publickey-302811860.html
- SourceTree - Permission denied (publickey): https://community.atlassian.com/t5/Sourcetree-questions/Permission-denied-publickey/qaq-p/594966
- ssh-agent(1) - Linux man page: https://linux.die.net/man/1/ssh-agent
- Ubuntu 18.04 Pyenv Build Python 3.7 Common Error: https://code.luasoftware.com/tutorials/linux/ubuntu-pyenv-build-python-37-common-error/
- Dotfiles – What is a Dotfile and How to Create it in Mac and Linux: https://www.freecodecamp.org/news/dotfiles-what-is-a-dot-file-and-how-to-create-it-in-mac-and-linux/
