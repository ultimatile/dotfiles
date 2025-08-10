#!/bin/bash
set -eu
pr_id="$1"
branch=$(gh pr view "$pr_id" --json headRefName --jq .headRefName)
repo_name=$(basename "$(git rev-parse --show-toplevel)")
dir_name="${repo_name}-${branch//\//_}"
git fetch upstream "pull/${pr_id}/head:${branch}"
git worktree add "../${dir_name}" "$branch"
