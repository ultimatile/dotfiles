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

# A branch can live in only one worktree, so a second `git worktree add` for it
# always fails. Treat "already has a worktree" as a no-op success so the keybinding
# is idempotent instead of erroring on the second press.
existing=$(git worktree list --porcelain | awk -v ref="refs/heads/$branch" '
  /^worktree / { path = substr($0, 10) }
  /^branch /   { if (substr($0, 8) == ref) { print path; exit } }
')
if [[ -n "$existing" ]]; then
  echo "ブランチ '$branch' は既にワークツリーとして存在します: $existing"
  exit 0
fi

# The branch has no worktree yet, but the target path is occupied by something
# else (a leftover directory, or a detached/other-branch worktree at this path).
# `git worktree add` would fail with an opaque message; surface the state so the
# situation can be resolved deliberately rather than guessed at.
if [[ -e "$worktree_path" ]]; then
  echo "パス '$worktree_path' は既に存在しますが、ブランチ '$branch' のワークツリーではありません。" >&2
  echo "既存のワークツリー/ディレクトリを確認して対処してください:" >&2
  git worktree list >&2
  exit 1
fi

git worktree add "$worktree_path" "$branch"
