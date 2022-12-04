#！/bin/bash

feature_name=$1

echo "Setting new feature in 'worktree/${feature_name}'"
git worktree add -b ${feature_name} worktree/${feature_name} main
