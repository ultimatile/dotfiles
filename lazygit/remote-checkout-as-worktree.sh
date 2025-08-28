#!/bin/bash
set -eu
remote_name="$1"
remote_branch="$2"
repo_path=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_path")
branch_name=$(basename "$remote_branch")
git fetch "$remote_name" "$branch_name"
git worktree add -b "${branch_name}" "${repo_path}/../${repo_name}-${branch_name}" "${remote_name}/${branch_name}"
