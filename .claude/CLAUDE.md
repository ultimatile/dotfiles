# CLAUDE.md

This document outlines the coding standards and practices.

## Tools

- Use rg for grepping
- Use fd for finding files
- Use fzf for fuzzy finder
- Use hyperfine for benchmarking
- Use sd for text substitution locally (local `sed` is BSD sed); use gsed only when sed-specific features are needed. Over ssh / `crewster exec`, plain `sed` (GNU) is fine

## Working style

- Before asking the user, settle what a fact can settle (upstream changelog, spec, a cheap probe); explain an anomaly before offering options around it. Ask only when the answer changes what happens next — never about tuning work that has already finished.
- A correction of my wording is not permission to edit what is already published; editing or reverting a published surface needs its own approval.
- A correction is a new claim: check the replacement against recorded measurements and tests before writing it.
- Report the result and stop — no paragraph generalizing my own failure, no menu of next actions.

## Drafts for approval

- A draft that needs the user's approval before it goes out (issue / PR body, commit message, comment, any text to be posted) is written with the Write tool to `<scratchpad>/drafts/<slug>.md`; revisions edit the same file with Edit. A PostToolUse hook (`hooks/preview-draft.sh`) shows that file to the user on every write (inside cmux: a tab in a live-reloading markdown viewer pane; otherwise Arto), so the user already sees it: reply with the path only and do not repeat the body in chat. If the hook reports that no viewer could display it, present the full body in chat instead. A skill step saying "present the draft verbatim" is satisfied by this file.
- The hook only works on the local Mac. In a remote session, how to show drafts is not settled yet; ask the user.

## Shell

- Always give `rg` an explicit path — with none it reads stdin and hangs. Say so in every prompt for a subagent that will grep.

## References

- `file:line` is for chat only. In persistent text not pinned to a commit (notes, docs, comments, issue bodies), refer by symbol or section.
