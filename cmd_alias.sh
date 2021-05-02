#!/bin/sh

alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

# update datetime for current commit
alias gct_update='git commit --amend --no-edit --date "$(date +"%a %b %d %H:%M:%S %Y %z")"'

# docker customization
alias dkr_psf='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias dkr_if='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | sort -k 1 -h'
# remove any existed or created (failed) containers
alias dkr_rm_e='docker rm $(docker ps -f status=exited -f status=created -q)'
# remove any dangling images
alias dkr_rmi_d='docker rmi $(docker images -f dangling=true -q)'
# prune all unused data/stuff
alias dkr_sp='echo y | docker system prune'

# docker-compose customization
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
