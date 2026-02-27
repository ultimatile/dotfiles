#!/usr/bin/env bash
set -euo pipefail

for cmd in git gh jq rg; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' command is required." >&2
    exit 1
  fi
done

repo_path=$(git rev-parse --show-toplevel)
cd "$repo_path"

mode="${1:-status}"
target_branch="${2:-}"

remote=""
if git remote | rg -qx upstream; then
  remote="upstream"
elif git remote | rg -qx origin; then
  remote="origin"
else
  remote=$(git remote | head -n1 || true)
fi

if [[ -z "$remote" ]]; then
  echo "Error: no git remotes found." >&2
  exit 1
fi

remote_url=$(git remote get-url "$remote")
gh_repo=$(
  printf "%s\n" "$remote_url" \
    | sed -E 's#(git@github\.com:|https://github\.com/)##; s#\.git$##'
)
if [[ ! "$gh_repo" =~ .+/.+ ]]; then
  gh_repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
fi

current_branch=$(git branch --show-current || true)
busy_branches=$(
  git worktree list --porcelain \
    | awk '/^branch refs\/heads\//{sub("^branch refs/heads/",""); print}'
)

is_protected_branch() {
  case "$1" in
    main | master | develop)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_busy_branch() {
  printf "%s\n" "$busy_branches" | rg -qx "$1"
}

find_merged_pr_for_branch_sha() {
  local branch="$1"
  local branch_sha prs_json prs_count pr_number merged_at

  branch_sha=$(git rev-parse "$branch")
  prs_json=$(gh pr list -R "$gh_repo" --state merged --head "$branch" --json number,mergedAt --limit 30)
  prs_count=$(printf "%s" "$prs_json" | jq 'length')
  if [[ "$prs_count" -eq 0 ]]; then
    return 1
  fi

  while IFS=$'\t' read -r pr_number merged_at; do
    if gh pr view "$pr_number" -R "$gh_repo" --json commits --jq '.commits[].oid' | rg -qx "$branch_sha"; then
      printf "%s\t%s\n" "$pr_number" "$merged_at"
      return 0
    fi
  done < <(printf "%s" "$prs_json" | jq -r 'sort_by(.mergedAt) | reverse | .[] | [.number, .mergedAt] | @tsv')

  return 2
}

list_candidate_branches_for_menu() {
  local branch match
  mapfile -t branches < <(git for-each-ref --format='%(refname:short)' refs/heads | sort)

  for branch in "${branches[@]}"; do
    if is_protected_branch "$branch"; then
      continue
    fi
    if [[ "$branch" == "$current_branch" ]]; then
      continue
    fi
    if is_busy_branch "$branch"; then
      continue
    fi

    if match=$(find_merged_pr_for_branch_sha "$branch"); then
      printf "%s\t%s\n" "$branch" "$match"
    fi
  done
}

print_status_table() {
  local branch match prs_json latest_pr latest_merged_at

  printf "repo: %s\n" "$repo_path"
  printf "pr-repo: %s (remote=%s)\n" "$gh_repo" "$remote"
  echo
  printf "%-10s %-50s %s\n" "status" "branch" "detail"
  printf "%-10s %-50s %s\n" "------" "------" "------"

  mapfile -t branches < <(git for-each-ref --format='%(refname:short)' refs/heads | sort)
  for branch in "${branches[@]}"; do
    if is_protected_branch "$branch"; then
      continue
    fi

    if [[ "$branch" == "$current_branch" ]]; then
      printf "%-10s %-50s %s\n" "skip" "$branch" "current branch"
      continue
    fi

    if is_busy_branch "$branch"; then
      printf "%-10s %-50s %s\n" "skip" "$branch" "used by worktree"
      continue
    fi

    if match=$(find_merged_pr_for_branch_sha "$branch"); then
      printf "%-10s %-50s %s\n" "candidate" "$branch" "merged PR #${match%%$'\t'*} at ${match#*$'\t'}"
      continue
    fi

    prs_json=$(gh pr list -R "$gh_repo" --state merged --head "$branch" --json number,mergedAt --limit 30)
    if [[ "$(printf "%s" "$prs_json" | jq 'length')" -eq 0 ]]; then
      printf "%-10s %-50s %s\n" "keep" "$branch" "no merged PR"
      continue
    fi

    latest_pr=$(printf "%s" "$prs_json" | jq -r 'sort_by(.mergedAt) | reverse | .[0].number')
    latest_merged_at=$(printf "%s" "$prs_json" | jq -r 'sort_by(.mergedAt) | reverse | .[0].mergedAt')
    printf "%-10s %-50s %s\n" "review" "$branch" "name matched merged PR #$latest_pr at $latest_merged_at, but tip differs"
  done

  echo
  echo "candidate: local tip SHA is included in merged PR commits (safe deletion candidate)."
  echo "review: merged PR exists for the same branch name, but local tip SHA differs."
}

delete_candidate_branch() {
  local branch="$1"
  local match pr_number merged_at

  if [[ -z "$branch" ]]; then
    echo "Error: branch name is required." >&2
    exit 1
  fi

  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Error: local branch '$branch' does not exist." >&2
    exit 1
  fi

  if is_protected_branch "$branch"; then
    echo "Error: protected branch '$branch' cannot be deleted." >&2
    exit 1
  fi

  if [[ "$branch" == "$current_branch" ]]; then
    echo "Error: current branch '$branch' cannot be deleted." >&2
    exit 1
  fi

  if is_busy_branch "$branch"; then
    echo "Error: branch '$branch' is currently used by another worktree." >&2
    exit 1
  fi

  if ! match=$(find_merged_pr_for_branch_sha "$branch"); then
    echo "Error: branch '$branch' is not a merged-PR SHA match candidate." >&2
    exit 1
  fi

  pr_number="${match%%$'\t'*}"
  merged_at="${match#*$'\t'}"

  echo "Deleting local branch '$branch' (matched merged PR #$pr_number at $merged_at)..."
  git branch -D "$branch"
  echo "Deleted '$branch'."
}

interactive_delete_loop() {
  local selection branch pr merged_at answer candidates_count

  while true; do
    mapfile -t candidates < <(list_candidate_branches_for_menu)
    candidates_count="${#candidates[@]}"

    if [[ "$candidates_count" -eq 0 ]]; then
      echo "No merged-PR deletion candidates."
      return 0
    fi

    echo "Select a branch to delete (ESC/Ctrl-C to exit):"
    selection=$(
      printf "%s\n" "${candidates[@]}" \
        | fzf \
            --delimiter=$'\t' \
            --with-nth=1,2,3 \
            --layout=reverse \
            --height=80% \
            --prompt="delete-branch> " \
            --header=$'branch\tpr\tmergedAt'
    ) || return 0

    branch="${selection%%$'\t'*}"
    pr="${selection#*$'\t'}"
    pr="${pr%%$'\t'*}"
    merged_at="${selection##*$'\t'}"

    printf "Delete local branch '%s' (PR #%s merged %s)? [y/N]: " "$branch" "$pr" "$merged_at"
    read -r answer
    case "$answer" in
      y | Y | yes | YES)
        delete_candidate_branch "$branch"
        echo
        ;;
      *)
        echo "Skipped '$branch'."
        echo
        ;;
    esac
  done
}

case "$mode" in
  --menu)
    list_candidate_branches_for_menu
    ;;
  --delete)
    delete_candidate_branch "$target_branch"
    ;;
  --interactive)
    interactive_delete_loop
    ;;
  status | --status)
    print_status_table
    ;;
  *)
    echo "Usage: $0 [--menu | --delete <branch> | --interactive | --status]" >&2
    exit 1
    ;;
esac
