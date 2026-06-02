#!/bin/bash
# Block direct python/pip and conda-family commands; suggest uv alternatives.
# This user manages Python tooling with uv. Conda / pixi / mamba / micromamba
# are not in use; suggestions to install or invoke them are reflex-prior failures
# rather than informed choices, so they are denied at hook time as a safety net
# on top of permissions.deny.

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

# Strip quoted substrings before pattern matching. The checks below scan the raw
# command text, which has no notion of shell quoting, so a keyword or command
# separator appearing inside a string literal (echo messages, commit text, the
# semicolon in `echo "...; conda removed"`) would otherwise false-positive.
# This is a heuristic, not a real parser: it accepts the rare false negative of a
# blocked command genuinely hidden inside quotes (e.g. bash -c "conda ...") in
# exchange for not firing on prose that merely mentions these tools.
SCAN=$(printf '%s' "$COMMAND" | sed -E -e 's/"[^"]*"//g' -e "s/'[^']*'//g")

if echo "$SCAN" | grep -q 'python3 -m pytest\|python -m pytest'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use `uv run pytest` instead of `python3 -m pytest`"
    }
  }'
elif echo "$SCAN" | grep -qE '(^|[;&|] *)(pip3?|python3? -m pip) '; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use `uv add` instead of pip/pip3"
    }
  }'
elif echo "$SCAN" | grep -qE '(^|[;&|] *)(conda|mamba|micromamba|pixi)( |$)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "conda / pixi / mamba family is not used in this user'\''s projects. Use uv for Python environments and dependencies."
    }
  }'
fi
