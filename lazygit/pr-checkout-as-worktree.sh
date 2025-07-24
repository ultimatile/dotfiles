#!/bin/bash

pr_id="$1"

# PR の headRefName を取得
branch=$(gh pr view "$pr_id" --json headRefName -q .headRefName)

# ルートレポジトリ名を取得
repo_name=$(basename "$(git rev-parse --show-toplevel)")

# ブランチ名のスラッシュをアンダースコアに変換（ディレクトリ名用）
safe_branch_name="${branch//\//_}"

# ブランチを fetch → worktree に追加
git fetch upstream "$branch"
git worktree add "../${repo_name}-$safe_branch_name" "$branch"