
This is repo for experiments of any greenfield technologies.

To push this repo from local to Github:

```sh
git remote add origin https://github.com/CastielWong/Laboratory.git
git push -u origin master
```

## Setup

### Pre-commit

It's a good practice to have [pre-commit](https://pre-commit.com/) in git repository for the purpose of code linting and formatting. Since most of the scripts involved would be in Python, to make the environment clean and easy to manage, [pyenv](https://github.com/pyenv/pyenv) is used to manage Python version and libraries.

For Mac user, it's suggested to install [Homebrew](https://brew.sh/) to get "pyenv"

```sh
# update Homebrew
brew update
brew install pyenv
# verify pyenv has been installed
brew list
```

Then follow steps below to activate "pyenv" and setup "pre-commit":

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

### Submodule

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
