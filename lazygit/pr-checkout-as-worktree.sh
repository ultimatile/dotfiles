#!/bin/bash
pr_id="$1"
branch=$(gh pr view "$pr_id" --json headRefName -q .headRefName)
repo_name=$(basename "$(git rev-parse --show-toplevel)")
slashless_branch_name="${branch//\//_}"
git fetch upstream "$branch"
git worktree add "../${repo_name}-$slashless_branch_name" "$branch"
