#!/usr/bin/env bash
set -euo pipefail
pr="$1"
repo_path=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_path")
branch_name=$(gh pr view "$pr" --json headRefName --jq .headRefName | xargs basename)
wt="${repo_path}/../${repo_name}-${branch_name}"
echo "Creating worktree for PR #${pr} (${branch_name}) with tracking branch..."
# Create empty worktree (checkout will be done by gh later)
git worktree add --no-checkout "$wt"
cd "$wt"
gh -R "$(gh repo view --json nameWithOwner --jq .nameWithOwner)" pr checkout "$pr" -b "${branch_name}"
echo "PR #${pr} checked out as tracked worktree at: $wt"
echo "Worktree path: $wt"
echo "Branch: ${branch_name} (with tracking)"
