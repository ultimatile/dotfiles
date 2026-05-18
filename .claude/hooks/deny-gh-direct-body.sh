#!/bin/bash
# Block direct gh invocations that carry a body, forcing them through the
# ~/.local/bin/gh-post wrapper which validates every body via stream input
# (file or stdin).
#
# Scope (v2):
#   - gh issue {create,edit,comment} with --body, --body-file, --body=, --body-file=
#   - gh pr    {create,edit,comment} with the same flags
#   - gh api repos/.../pulls/N/comments/M/replies   with -F body= / -f body= / --field body= / --raw-field body=
#   - gh api repos/.../{issues,pulls}/comments/N    with the same body= flags
#     (covers the PATCH single-comment edit path served by gh-post comment-edit)
#
# Out of scope (allowed to pass through):
#   - Other gh api ... -F body= paths not listed above (rare in practice;
#     extend this hook if a new survey shows non-trivial volume)
#   - gh pr review --body (zero historical use)
#   - gh pr merge       (zero historical use)
#   - read-only gh commands
#
# Bypass model: PreToolUse hooks fire per top-level Bash tool call, not on
# subprocesses spawned within a script. So the wrapper's own internal
# `gh ... --body-file <tmp>` and `gh api ... --input <jsonfile>` calls are
# invisible to this hook. No explicit bypass token is needed; the wrapper is
# allowed simply because its top-level command string is
# `~/.local/bin/gh-post ...`, not `gh ...`. The wrapper additionally avoids
# `-F body=` for the api paths (uses `--input <jsonfile>` instead), so even
# if hook visibility ever changed, the body= regex below would not false-fire.

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

emit_deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
}

# Match direct gh (issue|pr) (create|edit|comment) carrying any body flag.
# Use rg with -P (PCRE) so we can require both a subcommand match AND a body
# flag on the same logical command. The body-flag alternatives intentionally
# match --body / --body= / --body-file / --body-file= but not --body-stdin
# (which gh does not have and gh-post does).
if printf '%s' "$COMMAND" \
  | rg -qP '\bgh\s+(issue|pr)\s+(create|edit|comment)\b'; then
  if printf '%s' "$COMMAND" \
    | rg -qP '(?<!-)--body(=|\s|$)|--body-file(=|\s)'; then
    emit_deny "Direct gh body invocation blocked. Use ~/.local/bin/gh-post instead, which validates every body via --body-file or --body-stdin. See https://github.com/ultimatile/gh-post for usage."
    exit 0
  fi
fi

# Match direct `gh api` carrying a body= value on one of the wrapped
# resource paths. The body-flag pattern covers every shape gh's pflag
# accepts: short `-F` / `-f` with space / equals / cluster, and long
# `--field` / `--raw-field` with space or equals. Anchored so an
# inner substring like `--no-field body=...` does not false-fire.
if printf '%s' "$COMMAND" | rg -qP '\bgh\s+api\b'; then
  if printf '%s' "$COMMAND" \
    | rg -qP '(?<![A-Za-z0-9_-])((-F|-f)\s*=?\s*|--(raw-)?field(=|\s+))body='; then
    # Reply-to-thread endpoint (POST). More specific than the single-comment
    # pattern below — checked first so its tailored deny message wins. The
    # two endpoint shapes are otherwise disjoint (replies has `/N/comments/M/`
    # while single-comment is `/comments/M` with no intermediate `/N/`).
    if printf '%s' "$COMMAND" \
      | rg -qP 'repos/[^/[:space:]]+/[^/[:space:]]+/pulls/[0-9]+/comments/[0-9]+/replies\b'; then
      emit_deny "Direct gh api inline-reply with body= blocked. Use ~/.local/bin/gh-post reply-inline OWNER/REPO PR < replies.jsonl, which validates every body before any send. See https://github.com/ultimatile/gh-post for usage."
      exit 0
    fi
    # Single-comment PATCH endpoint (issue comments and PR review-thread
    # comments alike). Triggered when body= appears in the same command;
    # any HTTP method (POST/PATCH/PUT) is treated the same since the
    # concern is the unvalidated body, not the method.
    if printf '%s' "$COMMAND" \
      | rg -qP 'repos/[^/[:space:]]+/[^/[:space:]]+/(issues|pulls)/comments/[0-9]+\b'; then
      emit_deny "Direct gh api comment-edit with body= blocked. Use ~/.local/bin/gh-post comment-edit <url-or-id> --body-file PATH, which validates the body via the wrapper's hardwrap validator. See https://github.com/ultimatile/gh-post for usage."
      exit 0
    fi
  fi
fi

exit 0
