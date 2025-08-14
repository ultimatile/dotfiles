#!/bin/bash
set -eu
pr_id="$1"
branch=$(gh pr view "$pr_id" --json headRefName --jq .headRefName)
repo_path=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_path")
git fetch upstream "pull/${pr_id}/head:${branch}"
git worktree add "${repo_path}/../${repo_name}-${branch}" "$branch"
