#!/bin/bash
# Block direct python/pip and conda-family commands; suggest mise/uv alternatives.
# This user manages Python tooling with mise + uv. Conda / pixi / mamba / micromamba
# are not in use; suggestions to install or invoke them are reflex-prior failures
# rather than informed choices, so they are denied at hook time as a safety net
# on top of permissions.deny.

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
elif echo "$COMMAND" | grep -qE '(^|[;&|] *)(conda|mamba|micromamba|pixi)( |$)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "conda / pixi / mamba family is not used in this user'\''s projects. Use mise + uv for Python environments and dependencies."
    }
  }'
fi
