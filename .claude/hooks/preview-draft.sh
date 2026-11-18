#!/usr/bin/env bash
# PostToolUse(Edit|Write): show an approval draft written under <scratchpad>/drafts/ to the user.
# Inside cmux: one markdown viewer pane per session, one tab per draft; the viewer live-reloads,
# so a draft that already has a tab needs nothing. Outside cmux: Arto, with drafts/ in the sidebar.
# When neither can show it, tell the model so it presents the body in chat instead.
IN=$(cat)
if command -v jq >/dev/null; then
  FILE=$(jq -r '.tool_input.file_path // empty' <<<"$IN")
elif [[ $IN =~ \"file_path\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
  FILE=${BASH_REMATCH[1]}
fi
case "$FILE" in
  /private/tmp/claude-*/scratchpad/drafts/*.md | /tmp/claude-*/scratchpad/drafts/*.md) ;;
  *) exit 0 ;;
esac
DRAFTS="${FILE%%/scratchpad/drafts/*}/scratchpad/drafts"

# printf, not jq: this must still work where jq is missing. The path matched the case
# pattern above, so only " and \ need escaping.
not_shown() {
  local f=${FILE//\\/\\\\}
  f=${f//\"/\\\"}
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"preview-draft: no viewer could display %s. The user has NOT seen this draft; present its full body in chat."}}\n' "$f"
  exit 0
}

CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
if [ -n "$CMUX_WORKSPACE_ID" ] && [ -x "$CMUX" ] && "$CMUX" ping >/dev/null 2>&1; then
  # path<TAB>surface ref of the tab opened for it; scratchpad is per session, so this is too
  STATE="$DRAFTS/.cmux-viewer.tsv"
  PANELS=$("$CMUX" --json list-panels 2>/dev/null)
  live() { jq -r --arg r "$1" '.surfaces[] | select(.ref == $r and .type == "markdown") | .pane_ref' <<<"$PANELS"; }

  pane=""
  if [ -f "$STATE" ]; then
    known=$(awk -F'\t' -v p="$FILE" '$1 == p { s = $2 } END { print s }' "$STATE")
    [ -n "$known" ] && [ -n "$(live "$known")" ] && exit 0
    # pane of any tab this session opened that is still alive
    while IFS=$'\t' read -r _ ref; do
      p=$(live "$ref")
      [ -n "$p" ] && pane=$p
    done <"$STATE"
  fi

  out=$("$CMUX" markdown open "$FILE" --focus false 2>/dev/null) || not_shown
  [[ $out =~ surface=(surface:[0-9]+) ]] || not_shown
  surface=${BASH_REMATCH[1]}
  [ -n "$pane" ] && "$CMUX" move-surface --surface "$surface" --pane "$pane" --focus false >/dev/null 2>&1
  printf '%s\t%s\n' "$FILE" "$surface" >>"$STATE"
  exit 0
fi

if pgrep -qx arto 2>/dev/null; then
  arto --behind --directory="$DRAFTS" "$FILE" >/dev/null 2>&1 && exit 0
elif [ -d /Applications/Arto.app ]; then
  open -g -a Arto "$FILE" 2>/dev/null && exit 0
fi
not_shown
