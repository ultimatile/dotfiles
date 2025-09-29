#!/usr/bin/env bash
set -euo pipefail
pr="$1"
repo_path=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_path")

# 1) Keep headRefName as-is; only sanitize for display and directory usage.
head_ref=$(gh pr view "$pr" --json headRefName --jq .headRefName)
safe_ref="${head_ref//\//-}"   # Sanitized variant for directory names

# Guard against worktree directory collisions (PR may already be checked out)
wt="${repo_path}/../${repo_name}-${safe_ref}"
if [[ -e "$wt" ]]; then
  echo "Error: Directory '$wt' already exists. PR may already be checked out." >&2
  exit 1
fi

echo "Creating worktree for PR #${pr} (${head_ref}) with tracking branch..."

# 2) Initialize the worktree, then check out with an explicit local branch name (-b)
local_branch="pr-${pr}-${safe_ref}"
git worktree add --no-checkout "$wt"
cd "$wt"
gh -R "$(gh repo view --json nameWithOwner --jq .nameWithOwner)" \
   pr checkout "$pr" -b "$local_branch"

# 3) Capture the branch that actually ended up checked out as a safeguard
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 4) If branch.<name>.remote stored a URL, rewrite it to a real remote (ssh/https/enterprise safe)
url_or_remote="$(git config --get "branch.${current_branch}.remote" || true)"
if [[ "$url_or_remote" =~ ://|@.*: ]]; then
  # Query owner/name/sshUrl for the PR head repository
  head_repo_info="$( \
    gh pr view "$pr" --json headRepository \
      --jq '[.headRepository.owner.login // "", .headRepository.name // "", .headRepository.sshUrl // ""] | @tsv' \
  )"
  read -r head_owner head_repo head_ssh <<<"$head_repo_info"

  # Fall back to extracting owner/repo from the existing URL when data is incomplete
  if [[ -z "$head_owner" || -z "$head_ssh" ]]; then
    fork_url="$url_or_remote"
    # Extract owner/repo from the remote URL
    if [[ "$fork_url" =~ git@github\.com:([^/]+)/([^.]+)\.git ]]; then
      head_owner="${BASH_REMATCH[1]}"
      head_repo="${BASH_REMATCH[2]}"
    elif [[ "$fork_url" =~ https://github\.com/([^/]+)/([^/]+)$ ]]; then
      head_owner="${BASH_REMATCH[1]}"
      head_repo="${BASH_REMATCH[2]}"
    fi
  else
    fork_url="$head_ssh"  # Prefer sshUrl
  fi

  # 5) Reuse an existing remote or create a unique owner-repo[-n] name
  remote_name=""
  for r in $(git remote); do
    if [[ "$(git remote get-url "$r" 2>/dev/null || true)" == "$fork_url" ]]; then
      remote_name="$r"; break
    fi
  done
  if [[ -z "$remote_name" ]]; then
    candidate="${head_owner}-${head_repo}"
    remote_name="$candidate"
    if git remote | grep -qx "$remote_name"; then
      i=2; while git remote | grep -qx "${candidate}-${i}"; do ((i++)); done
      remote_name="${candidate}-${i}"
    fi
    git remote add "$remote_name" "$fork_url"
  fi

  # 6) Fetch the head ref and point the upstream to remote/headRefName
  git fetch "$remote_name" "$head_ref"
  git branch --set-upstream-to="$remote_name/$head_ref" "$current_branch"
  echo "Added remote '$remote_name' and set tracking to $remote_name/$head_ref"
fi

echo "PR #${pr} checked out as tracked worktree at: $wt"
echo "Worktree path: $wt"
echo "Branch: ${current_branch} (with tracking)"
