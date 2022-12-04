#！/bin/bash

feature_name=$1

dir_feature="worktree/${feature_name}"

echo "Cleaning up branch in '${dir_feature}'..."
rm -rf ${dir_feature}
git worktree prune
echo "Branch ${feature_name} is pruned"
