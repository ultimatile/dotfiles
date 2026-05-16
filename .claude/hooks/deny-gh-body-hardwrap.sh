#!/bin/bash
# Block `gh (issue|pr) (create|edit) --body "$(cat <<'TAG' ... TAG ...)"` when
# the body contains hard-wrapped paragraphs. Companion to gh-body-conventions
# § Formatting (semantic line breaks, not column wrapping).
#
# Heuristic: a paragraph is hard-wrapped if it contains 3+ consecutive non-blank
# prose lines, each 50-85 bytes long, and none of them ends in a sentence /
# clause / block terminator (. ! ? : ; , ) ] } > " ' ` ). Sentence-per-line and
# clause-per-line styles end every line in a terminator and are exempt.
#
# Scope: heredoc-style --body only. --body-file <path> is out of scope (the
# body is in a file the hook would have to read separately). Japanese-dominant
# bodies fall outside the detector's byte band and are not covered here.

export LC_ALL=C

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

if [ -z "$COMMAND" ] || [ "$COMMAND" = "null" ]; then
  exit 0
fi

# Restrict to gh (issue|pr) (create|edit) invocations with a --body flag.
if ! printf '%s' "$COMMAND" | grep -qE '\bgh +(issue|pr) +(create|edit)\b'; then
  exit 0
fi
if ! printf '%s' "$COMMAND" | grep -qE -- '--body([ 	=]|$)'; then
  exit 0
fi

# Extract the heredoc body that follows --body.
# Tracks: scan → after_body → in_body. The first heredoc opener seen at or
# after --body becomes the body heredoc; lines until its closing tag are the
# body content. Earlier heredocs (e.g. a --title heredoc) are skipped via the
# scan-without-action state.
BODY=$(printf '%s\n' "$COMMAND" | awk '
  BEGIN { state = "scan"; tag = "" }
  state == "scan" {
    if (match($0, /--body([ \t=]|$)/)) {
      after = substr($0, RSTART + RLENGTH)
      if (match(after, /<<-?'\''?[A-Za-z_][A-Za-z_0-9]*'\''?/)) {
        raw = substr(after, RSTART, RLENGTH)
        sub(/^<<-?/, "", raw)
        gsub(/'\''/, "", raw)
        tag = raw
        state = "in_body"
        next
      }
      state = "after_body"
      next
    }
    next
  }
  state == "after_body" {
    if (match($0, /<<-?'\''?[A-Za-z_][A-Za-z_0-9]*'\''?/)) {
      raw = substr($0, RSTART, RLENGTH)
      sub(/^<<-?/, "", raw)
      gsub(/'\''/, "", raw)
      tag = raw
      state = "in_body"
      next
    }
    next
  }
  state == "in_body" {
    if ($0 ~ "^[ \t]*" tag "[ \t]*$") { exit }
    print
  }
')

if [ -z "$BODY" ]; then
  exit 0
fi

# Hard-wrap detector. Skips fenced code, lists, blockquotes, headings, tables.
# Resets the consecutive-run counter on any line that breaks the wrap shape.
FLAGS=$(printf '%s\n' "$BODY" | awk '
  BEGIN { in_fence = 0; consec = 0; start_line = 0; out = "" }
  /^```/ || /^~~~/ { in_fence = !in_fence; consec = 0; next }
  in_fence { next }
  /^$/ { consec = 0; next }
  /^[ \t]*[-*+][ \t]/ { consec = 0; next }
  /^[ \t]*[0-9]+\.[ \t]/ { consec = 0; next }
  /^[ \t]*>/ { consec = 0; next }
  /^[ \t]*#/ { consec = 0; next }
  /^[ \t]*\|/ { consec = 0; next }
  {
    line = $0
    sub(/[ \t]+$/, "", line)
    n = length(line)
    if (n == 0) { consec = 0; next }
    last = substr(line, n, 1)
    is_end = (last == "." || last == "!" || last == "?" || \
              last == ":" || last == ";" || last == "," || \
              last == ")" || last == "]" || last == "}" || \
              last == ">" || last == "\"" || last == "`" || \
              last == "\047")
    if (n >= 50 && n <= 85 && !is_end) {
      if (consec == 0) start_line = NR
      consec++
      if (consec == 3) {
        out = out " body-line " start_line " (~" n " cols);"
      }
    } else {
      consec = 0
    }
  }
  END { if (out != "") print out }
')

if [ -n "$FLAGS" ]; then
  REASON="Hard-wrapped paragraph(s) detected in --body:${FLAGS}. Use semantic line breaks (one sentence or clause per line) instead of column wrapping. See gh-body-conventions § Formatting."
  jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
fi
