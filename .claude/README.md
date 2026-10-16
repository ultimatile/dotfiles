# .claude

## In-house tools

`settings.json` and the hooks call these tools of mine. Each repository's README
has install instructions.

| Tool | Used by |
| --- | --- |
| [`typst-cjk-latin-space-remover`](https://github.com/ultimatile/cjk-space-formatter/tree/main/crates/typst-cjk-latin-space-remover) | the `PostToolUse` hook in `settings.json`, which removes CJK–Latin spaces from every `.typ` file Claude edits |
| [`gh-post`](https://github.com/ultimatile/gh-post) | `hooks/deny-gh-direct-body.sh`, which blocks `gh` calls that pass an issue or PR body directly and points Claude to `gh-post` |
