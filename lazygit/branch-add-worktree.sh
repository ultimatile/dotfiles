#!/bin/bash
set -eu

branch="$1"

remote_url=$(git remote get-url origin)
if [[ "$remote_url" =~ ^git@([^:/]+)[:/]([^/]+)/(.+)$ ]] || [[ "$remote_url" =~ ^https://([^/]+)/([^/]+)/(.+)$ ]]; then
  host="${BASH_REMATCH[1]}"
  owner="${BASH_REMATCH[2]}"
  repo="${BASH_REMATCH[3]%.git}"
else
  echo "Error: Cannot parse remote URL: $remote_url" >&2
  exit 1
fi

worktree_path="$HOME/gwq/$host/$owner/$repo/$branch"
git worktree add "$worktree_path" "$branch"
