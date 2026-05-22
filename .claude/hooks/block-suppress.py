#!/usr/bin/env python3
# PreToolUse hook: blocks Rust suppression attributes (and any rule declared in
# suppress-policy.toml) unless the user has explicitly authorized them in their
# latest message via a bypass token.
#
# Policy lives in ~/.claude/hooks/suppress-policy.toml. Logic stays here.
# Exit 2 surfaces stderr to the agent and aborts the tool call.

import json
import pathlib
import re
import sys
import tomllib

POLICY_PATH = pathlib.Path.home() / ".claude/hooks/suppress-policy.toml"

# Per-tool fields whose textual content we scan for suppression patterns.
TOOL_FIELDS = {
    "Write":        ["content"],
    "Edit":         ["new_string"],
    "NotebookEdit": ["new_source"],
    "Bash":         ["command"],
}


def collect_blob(tool: str, tool_input: dict) -> str:
    fields = TOOL_FIELDS.get(tool, [])
    return "\n".join(str(tool_input.get(k, "")) for k in fields)


def latest_user_message(transcript_path: str) -> str:
    """Return the most recent user-authored message text from the JSONL transcript.

    Walks lines in reverse so we stop at the first match. Assistant turns are
    ignored — bypass tokens are valid only when they appear in a real user
    message, which the agent cannot fabricate.
    """
    try:
        lines = pathlib.Path(transcript_path).read_text().splitlines()
    except OSError:
        return ""
    for line in reversed(lines):
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        if rec.get("type") != "user":
            continue
        content = rec.get("message", {}).get("content", "")
        if isinstance(content, str):
            return content
        if isinstance(content, list):
            return "".join(
                block.get("text", "")
                for block in content
                if isinstance(block, dict)
            )
    return ""


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0  # malformed input: do not block

    tool = event.get("tool_name", "")
    tool_input = event.get("tool_input", {}) or {}
    blob = collect_blob(tool, tool_input)
    if not blob:
        return 0

    try:
        policy = tomllib.loads(POLICY_PATH.read_text())
    except (OSError, tomllib.TOMLDecodeError) as e:
        print(f"block-suppress: cannot load policy: {e}", file=sys.stderr)
        return 0  # fail-open: missing policy should not freeze the agent

    rules = policy.get("rule", [])
    user_msg_cache: str | None = None

    for rule in rules:
        if "tools" in rule and tool not in rule["tools"]:
            continue
        if not re.search(rule["pattern"], blob):
            continue

        rid = rule.get("id", "?")
        action = rule.get("action")

        if action == "block":
            msg = rule.get("message", rule["pattern"])
            print(f"blocked [{rid}]: {msg}", file=sys.stderr)
            return 2

        if action == "require_token":
            token = rule.get("token", "")
            if user_msg_cache is None:
                user_msg_cache = latest_user_message(event.get("transcript_path", ""))
            if token and token in user_msg_cache:
                continue
            print(
                f"blocked [{rid}]: requires `{token}` in the user's latest message",
                file=sys.stderr,
            )
            return 2

        # Unknown action: treat conservatively as block.
        print(f"blocked [{rid}]: unknown action {action!r}", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
