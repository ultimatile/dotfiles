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

# Fail-fast guard: if <branch> is checked out in a DIFFERENT worktree, we cannot
# force-move it (`git branch -f` refuses to touch a branch in use elsewhere).
# Detecting this BEFORE the detach in step 1 is essential: detaching first and
# then failing at step 2 would strand this worktree in detached HEAD — exactly
# the failure mode that produced orphaned detached gwq worktrees historically.
other_worktree=$(git worktree list --porcelain | awk -v ref="refs/heads/$branch" -v self="$worktree_path" '
  /^worktree / { path = substr($0, 10) }
  /^branch /   { if (substr($0, 8) == ref && path != self) { print path; exit } }
')
if [[ -n "$other_worktree" ]]; then
  echo "Error: branch '$branch' is checked out in another worktree: $other_worktree" >&2
  echo "Move that worktree off '$branch' first (e.g. switch it to another branch)." >&2
  exit 1
fi

# Crash-safe restore: once the worktree is detached (step 1), any early exit —
# a failed step, Ctrl-C, or SIGTERM — must not leave it stranded in detached
# HEAD. This EXIT trap re-attaches <branch> on any non-success path; it is
# disarmed only after step 3 completes.
detached=0
restore() {
  [[ "$detached" -eq 1 ]] || return 0
  echo "Restoring worktree state..." >&2
  git -C "$worktree_path" checkout "$branch" 2>/dev/null \
    || echo "Warning: could not re-attach '$branch' in $worktree_path (left detached; re-run after resolving)" >&2
}
trap restore EXIT

# Step 1: Detach the worktree HEAD.
# This releases <branch> so it can be freely force-moved in step 2. Detaching
# just repoints HEAD to the current commit without touching the working tree,
# so it is non-destructive and idempotent (re-detaching is a no-op).
echo "Detaching worktree HEAD..."
git -C "$worktree_path" checkout --detach
detached=1

# Step 2: Force-move (or create) <branch> to point at <base>.
# The fail-fast guard above guarantees no other worktree holds <branch>, and
# step 1 detached this one, so `git branch -f` succeeds regardless of prior
# state (existing/deleted/in-use).
echo "Pointing '$branch' at '$base'..."
git branch -f "$branch" "$base"

# Step 3: Re-attach the worktree by checking out <branch>.
# The worktree directory is reused, preserving untracked artifacts
# (node_modules/.venv/.env/build caches). If the working tree has changes
# that would be overwritten, git's own safety check refuses the checkout
# rather than clobbering local work (the EXIT trap then reports it).
echo "Re-attaching '$branch' to worktree..."
git -C "$worktree_path" checkout "$branch"

# Success: disarm the restore trap; the worktree is cleanly on <branch>.
detached=0
trap - EXIT
