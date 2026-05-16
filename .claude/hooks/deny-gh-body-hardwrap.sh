#!/bin/bash
# Block gh invocations that ship a hard-wrapped body to GitHub. Companion to
# gh-body-conventions § Formatting (semantic line breaks, not column wrapping).
#
# Sources of body content covered:
#
#   1. gh (issue|pr) (create|edit|comment) --body "$(cat <<TAG ... TAG ...)"
#   2. gh (issue|pr) (create|edit|comment) --body-file <path>
#   3. gh api ... -F body=@<path>            (file form; @-prefixed)
#
# Inline body strings on `gh api ... -f body="..."` or
# `gh api ... -F body="..."` are intentionally out of scope: extracting the
# value through awk past shell escaping is unreliable and produces false-
# positive blocks. Use heredoc / file form when filing prose bodies through
# `gh api` to stay inside the detector's coverage.
#
# Heuristic: a paragraph is hard-wrapped if it contains 3+ consecutive non-blank
# prose lines, each 50-85 bytes long, and none of them ends in a sentence /
# clause / block terminator (. ! ? : ; , ) ] } > " ' ` ). Sentence-per-line and
# clause-per-line styles end every line in a terminator and are exempt.
#
# Japanese-dominant bodies fall outside the detector's byte band and are not
# covered here.

export LC_ALL=C

COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)

if [ -z "$COMMAND" ] || [ "$COMMAND" = "null" ]; then
  exit 0
fi

# Identify which body-carrying gh shape this command is, if any.
IS_GH_SUBCMD=0
if printf '%s' "$COMMAND" | grep -qE '\bgh +(issue|pr) +(create|edit|comment)\b'; then
  IS_GH_SUBCMD=1
fi
IS_GH_API_FILE=0
if printf '%s' "$COMMAND" | grep -qE '\bgh +api\b' \
  && printf '%s' "$COMMAND" | grep -qE -- '-F[ 	]+body=@'; then
  IS_GH_API_FILE=1
fi

if [ "$IS_GH_SUBCMD" -eq 0 ] && [ "$IS_GH_API_FILE" -eq 0 ]; then
  exit 0
fi

# Strip surrounding single or double quotes from a path token.
unquote() {
  printf '%s' "$1" | sed -E "s/^['\"]//; s/['\"]$//"
}

BODY=""

# --- gh (issue|pr) (create|edit|comment) ---

if [ "$IS_GH_SUBCMD" -eq 1 ]; then
  # Branch A: --body-file <path>
  BODY_FILE_RAW=$(printf '%s' "$COMMAND" | grep -oE -- '--body-file[ 	=]+[^ 	]+' | head -1 | sed -E 's/^--body-file[ 	=]+//')
  if [ -n "$BODY_FILE_RAW" ]; then
    BODY_FILE=$(unquote "$BODY_FILE_RAW")
    if [ -r "$BODY_FILE" ]; then
      BODY=$(cat "$BODY_FILE")
    fi
  fi

  # Branch B: --body heredoc.
  # Tracks: scan → after_body → in_body. The first heredoc opener seen at or
  # after --body becomes the body heredoc; lines until its closing tag are the
  # body content. Earlier heredocs (e.g. a --title heredoc) are skipped via the
  # scan-without-action state.
  if [ -z "$BODY" ] && printf '%s' "$COMMAND" | grep -qE -- '--body([ 	=]|$)'; then
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
  fi
fi

# --- gh api ... -F body=@<path> ---

if [ "$IS_GH_API_FILE" -eq 1 ] && [ -z "$BODY" ]; then
  API_BODY_FILE_RAW=$(printf '%s' "$COMMAND" | grep -oE -- '-F[ 	]+body=@[^ 	]+' | head -1 | sed -E 's/^-F[ 	]+body=@//')
  if [ -n "$API_BODY_FILE_RAW" ]; then
    API_BODY_FILE=$(unquote "$API_BODY_FILE_RAW")
    if [ -r "$API_BODY_FILE" ]; then
      BODY=$(cat "$API_BODY_FILE")
    fi
  fi
fi

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
  REASON="Hard-wrapped paragraph(s) detected in body:${FLAGS}. Use semantic line breaks (one sentence or clause per line) instead of column wrapping. See gh-body-conventions § Formatting."
  jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
fi
