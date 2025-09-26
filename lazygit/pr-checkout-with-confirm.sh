#!/usr/bin/env bash
set -euo pipefail
pr_data="$1"
checkout_type="$2"
pr_num="${pr_data%% *}"
pr_title="${pr_data#* }"
# Remove surrounding quotes from title
pr_title="${pr_title#\"}"
pr_title="${pr_title%\"}"

echo "=== PR Checkout ==="
echo "PR #${pr_num}: \"${pr_title}\""
echo "Method: ${checkout_type}"
echo

case "$checkout_type" in
"通常チェックアウト")
	echo "Executing: gh pr checkout ${pr_num}"
	gh pr checkout "$pr_num"
	;;
"追跡ブランチ付きワークツリーでチェックアウト")
	echo "Executing: tracked worktree checkout"
	"$HOME"/dotfiles/lazygit/pr-checkout-as-worktree-tracked.sh "$pr_num"
	;;
"デタッチドワークツリーでチェックアウト")
	echo "Executing: detached worktree checkout"
	"$HOME"/dotfiles/lazygit/pr-checkout-as-worktree.sh "$pr_num"
	;;
*)
	echo "Unknown checkout type: $checkout_type"
	exit 1
	;;
esac

echo "PR #${pr_num} \"${pr_title}\" checkout completed!"
