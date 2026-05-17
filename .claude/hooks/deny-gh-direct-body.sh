#!/bin/bash
# Block direct `gh (issue|pr) (create|edit|comment)` invocations that carry a
# body, forcing them through the ~/.local/bin/gh-post wrapper which validates
# every body via stream input (file or stdin).
#
# Scope (v1, narrow):
#   - gh issue {create,edit,comment} with --body, --body-file, --body=, --body-file=
#   - gh pr    {create,edit,comment} with the same flags
#
# Out of scope for v1 (allowed to pass through):
#   - gh api ... -F body= / -f body= / -F body=@ (Copilot inline-reply workflow
#     remains alive until gh-post grows reply-inline)
#   - gh pr review --body (zero historical use)
#   - gh pr merge       (zero historical use)
#   - read-only gh commands
#
# Bypass model: PreToolUse hooks fire per top-level Bash tool call, not on
# subprocesses spawned within a script. So the wrapper's own internal
# `gh ... --body-file <tmp>` call is invisible to this hook. No explicit
# bypass token is needed; the wrapper is allowed simply because its top-level
# command string is `~/.local/bin/gh-post ...`, not `gh ...`.

export LC_ALL=C

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

if [ -z "$COMMAND" ] || [ "$COMMAND" = "null" ]; then
  exit 0
fi

# Skip when the top-level command is a git operation. Commit messages,
# tag messages, log queries, grep targets, etc. routinely contain the
# literal text "gh issue/pr create/edit/comment ... --body" without
# actually invoking gh, and regex-based intra-string detection cannot
# tell quoted argument content apart from real command position.
if printf '%s' "$COMMAND" | rg -qP '^\s*(cd\s+\S+\s*&&\s*)?git\s+'; then
  exit 0
fi

# Match direct gh (issue|pr) (create|edit|comment) carrying any body flag.
# Use rg with -P (PCRE) so we can require both a subcommand match AND a body
# flag on the same logical command. The body-flag alternatives intentionally
# match --body / --body= / --body-file / --body-file= but not --body-stdin
# (which gh does not have and gh-post does).
if printf '%s' "$COMMAND" \
  | rg -qP '\bgh\s+(issue|pr)\s+(create|edit|comment)\b'; then
  if printf '%s' "$COMMAND" \
    | rg -qP '(?<!-)--body(=|\s|$)|--body-file(=|\s)'; then
    REASON="Direct gh body invocation blocked. Use ~/.local/bin/gh-post instead, which validates every body via --body-file or --body-stdin. See https://github.com/ultimatile/gh-post for usage."
    jq -n --arg reason "$REASON" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
    exit 0
  fi
fi

exit 0
