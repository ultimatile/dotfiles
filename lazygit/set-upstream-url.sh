#!/bin/bash
set -euo pipefail

# Get current repository's OWNER/REPO format for gh commands
current_remote=$(git remote get-url origin)

# Extract owner/repo from various URL formats (SSH, HTTPS, custom SSH aliases)
# Handles: git@github.com:owner/repo.git, https://github.com/owner/repo.git, ssh://git@github.com/, alias:owner/repo, etc.
# TODO: consider more intuitive way https://chatgpt.com/share/68ab564a-1830-800f-9077-c5515e7f6915
owner_repo=$(echo "$current_remote" | sed -E 's#^(https://github\.com/|git@github\.com:|ssh://git@github\.com/|[^:/]+:)([^/]+/[^/]+)/?$#\2#' | sed 's/\.git$//')

# Get parent repository information using gh
parent_url=$(gh api repos/"$owner_repo" --jq '.source.clone_url // .parent.clone_url // empty')

if [ -z "$parent_url" ]; then
	echo "No parent repository found. This might not be a fork."
	exit 1
fi

# Add upstream remote
echo "Adding upstream remote: $parent_url"
git remote add upstream "$parent_url" 2>/dev/null || {
	echo "Upstream remote already exists. Updating URL..."
	git remote set-url upstream "$parent_url"
}

echo "Successfully set upstream to: $parent_url"
