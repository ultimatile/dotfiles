#!/usr/bin/env bash
set -euo pipefail

branch="$1"  # SelectedLocalBranch.Name — the branch to reset
base="$2"    # base branch the reset should point to (e.g. main)

# Resolve the worktree hosting <branch> via the git worktree registry.
# `gwq get` is avoided here because it falls back to an interactive fuzzy
# finder on ambiguous matches, which would hang when invoked from lazygit.
#
# First try to match by branch ref. This covers the normal case where the
# worktree is checked out to refs/heads/<branch>.
worktree_path=$(git worktree list --porcelain | awk -v bref="refs/heads/$branch" '
  $1 == "worktree" { path = $2 }
  $1 == "branch"   && $2 == bref { print path; exit }
')

# Fallback: the worktree may be in a detached HEAD state (e.g. after an
# explicit `detach`, or after the branch was deleted), so no `branch` line
# exists in `git worktree list --porcelain`. In that case, match by the
# directory basename, which follows the gwq path convention
# (`<basedir>/<host>/<owner>/<repo>/<branch>`).
if [[ -z "$worktree_path" ]]; then
  worktree_path=$(git worktree list --porcelain | awk -v b="$branch" '
    $1 == "worktree" {
      path = $2
      n = split(path, parts, "/")
      if (parts[n] == b) { print path; exit }
    }
  ')
fi

if [[ -z "$worktree_path" ]]; then
  echo "Error: No worktree found for branch '$branch'" >&2
  exit 1
fi

echo "Target worktree: $worktree_path"

# Step 1: Detach the worktree HEAD.
# This releases <branch> so it can be freely force-moved in step 2 regardless
# of which worktree currently holds it. Detaching just repoints HEAD to the
# current commit without touching the working tree, so it is non-destructive
# and idempotent (re-detaching an already-detached worktree is a no-op).
echo "Detaching worktree HEAD..."
git -C "$worktree_path" checkout --detach

# Step 2: Force-move (or create) <branch> to point at <base>.
# `git branch -f` refuses to touch a branch that is the current branch of any
# worktree — the detach in step 1 guarantees no worktree holds <branch>, so
# this succeeds regardless of the prior state (existing/deleted/in-use).
echo "Pointing '$branch' at '$base'..."
git branch -f "$branch" "$base"

# Step 3: Re-attach the worktree by checking out <branch>.
# The worktree directory is reused, preserving untracked artifacts
# (node_modules/.venv/.env/build caches). If the working tree has changes
# that would be overwritten, git's own safety check refuses the checkout
# rather than clobbering local work.
echo "Re-attaching '$branch' to worktree..."
git -C "$worktree_path" checkout "$branch"
