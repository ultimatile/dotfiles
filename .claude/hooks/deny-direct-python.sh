#!/bin/bash
# Block direct python/pip commands and suggest uv alternatives

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

if echo "$COMMAND" | grep -q 'python3 -m pytest\|python -m pytest'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use `uv run pytest` instead of `python3 -m pytest`"
    }
  }'
elif echo "$COMMAND" | grep -qE '(^|[;&|] *)(pip3?|python3? -m pip) '; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use `uv add` instead of pip/pip3"
    }
  }'
fi
