---
name: logseq-paper-notes
description: Create and update paper reading notes in the user's Logseq vault. Use when summarizing a paper, recording results from a paper reading session, or appending notes to an existing paper page. The vault is shared between Logseq (daily-use viewer) and Obsidian (CLI access). Writes use Logseq syntax (key:: value, tab-indented outline), reads can use Obsidian CLI for backlinks/search or rg for raw content.
---

# Logseq Paper Notes

Manage paper notes in the user's Logseq vault using a fuzzy convention: minimal file naming/property rules, rg for search, and Obsidian CLI for graph operations (backlinks, tag listing, search).

## Vault location

- Pages directory: `$LOGSEQ_PAGES_ROOT` (resolve via `fish -i -c 'echo $LOGSEQ_PAGES_ROOT'` if env var isn't visible from bash)
- Layout: flat — all pages live directly under the pages directory, no subdirectories
- Vault is also registered in Obsidian as vault name `pages` with `"cli":true`

## File naming

Two categories of paper notes coexist in the vault:

1. **Zotero-imported notes** — filenames start with `@` (e.g. `@A survey on the complexity of learning quantum states.md`).
   - **NEVER create new files with `@` prefix.** This prefix is reserved for Zotero importer output.
   - When the agent finds an existing `@`-file matching a paper, **append** to it instead of creating a new file.

2. **Agent-created notes** — choose filename in this order:
   - If arxiv ID is known: `{arxiv_id}.md` (e.g. `2401.12345.md`)
   - If DOI is known but no arxiv ID: `{doi-slug}.md` with `/` → `_`
   - Otherwise: short English-title `.md` (no `@` prefix)
   - URL-encode `:` → `%3A` and other filesystem-unsafe chars (matching the Zotero convention used in existing notes)

## Property format (Logseq syntax)

Logseq page properties are `key:: value` lines (NOT YAML frontmatter) and **must be the first block of the page** to be recognized as page properties.

When creating a new agent-managed note, write only properties the agent can confidently fill:

```
tags:: [[Tag1]], [[Tag2]]
authors:: [[Firstname Lastname]], [[Another Author]]
date:: YYYY-MM-DD
item-type:: [[preprint]]
title:: Paper Full Title
arxiv-id:: 2401.XXXXX
doi:: 10.XXXX/YYYY
url:: https://arxiv.org/abs/2401.XXXXX
```

Notes:
- `item-type` values seen in existing notes: `[[preprint]]`, `[[journalArticle]]`. Match those.
- `tags::` and `authors::` use `[[page link]]` syntax with comma separation.
- Do NOT include Zotero-specific properties (`library-catalog`, `access-date`, `zotero://` links, `extra::`) — those are meaningful only for Zotero-imported notes.

After the property block, use Logseq outline structure with **tab indentation**:

```
- [[Abstract]]
	- Paper abstract here.
- [[Notes]]
	- Freeform reading notes — summary, key results, and comments all go here as sub-blocks.
```

**Which `[[...]]` section headers are real, and why they are links.** Only three section headers actually recur in the vault and aggregate across the graph: `[[Abstract]]` (~600 notes), `[[Attachments]]` (~675 — Zotero-machine-generated, carries `{{zotero-imported-file ...}}` macros; present when **appending** to a `@` note, do NOT fabricate it in agent-created notes), and `[[Notes]]` (~125). They are wikilinks on purpose: opening `[[Abstract]]` collects every paper's abstract via linked references (Logseq materializes the page from the references even with no `Abstract.md` file). Do NOT invent sparse sections — earlier versions of this skill listed `[[Summary]]` (2 uses) and `[[Key results]]` (0 uses), which aggregate nothing and just create near-orphan pages; fold that content under `[[Notes]]`. This link-as-section idiom is specific to **paper notes**: for non-paper or uncurated notes (e.g. a brainstorm log), use plain text or `**bold**` headers, because every `[[...]]` spawns a page (junk like a `Seed`/`Status` page). Reserve `[[...]]` for nodes you actually want in the graph.

## Discover existing tag vocabulary before adding new tags

Before inventing a new tag, check what's already used:

```bash
rg -oN --no-filename '^tags::.*' "$LOGSEQ_PAGES_ROOT" \
  | rg -o '\[\[[^\]]+\]\]' | sort -u
```

Match existing capitalization and structure (e.g. `[[Quantum Physics]]`, `[[Computer Science - Machine Learning]]`).

## Searching/querying notes

### Find a paper by arxiv ID, DOI, or partial title (use rg)

```bash
rg -l 'arxiv-id:: 2401' "$LOGSEQ_PAGES_ROOT"
rg -l 'doi:: 10.1103' "$LOGSEQ_PAGES_ROOT"
fd -i 'partial title' "$LOGSEQ_PAGES_ROOT"
```

### List notes with a given tag

```bash
rg -l 'tags::.*\[\[Tensor Network' "$LOGSEQ_PAGES_ROOT"
```

### Backlinks / link graph (use Obsidian CLI)

Obsidian CLI gives graph-aware operations rg cannot:

```bash
obsidian backlinks file="@Tensor Network Representations of Parton Wave Functions" format=json
obsidian links file=2401.12345
obsidian unresolved
obsidian orphans
obsidian tags
```

Obsidian CLI requires the GUI to be running with the `pages` vault open. If commands return `Vault not found.`, launch with `open -a Obsidian` and wait ~5s before retrying.

### Full-text search

```bash
obsidian search query="VQ-VAE" format=json
# or via rg
rg -l 'VQ-VAE' "$LOGSEQ_PAGES_ROOT"
```

## Writing notes

### Creating a new note

Use the `Write` tool to write Logseq-format content directly. This is the most predictable path and avoids any CLI quirks. Place the file at `$LOGSEQ_PAGES_ROOT/{filename}.md`.

Alternative: `obsidian create path={filename}.md content='...'` — equivalent, with `\n`/`\t` escape sequences. Useful only when running other Obsidian CLI ops in the same session and wanting Obsidian's index updated immediately.

### Appending to an existing note (especially Zotero `@` notes)

Use the `Edit` tool to append a new outline block (`- [[Notes]]\n\t- ...`) at the end of the file. Preserve the existing outline structure and indentation (tabs).

Alternative: `obsidian append path={filename}.md content='- [[Notes]]\n\t- text'` — adds a blank line then the content at end of file.

### Prohibited: `obsidian property:set` / `property:remove` on Logseq-managed files

These commands inject YAML frontmatter (`---\nkey: value\n---`) at the top of the file. Logseq requires page properties to be in the first block, so the frontmatter pushes existing `key:: value` lines out of property position and they stop being recognized as page properties in Logseq. **Do not use these commands on this vault.**

To update properties, edit the `key:: value` lines directly with the `Edit` tool.

## Quick reference: Obsidian CLI parameter quirks

- `property:set` uses `name=` (not `key=`)
- `search` uses `query=` (not positional)
- `vault=<name>` defaults to active vault if omitted
- Many commands support `format=json|tsv|csv`
- `file=<name>` resolves like wikilinks (basename match), `path=<path>` is exact relative path
- `delete` moves to trash (no visible `.trash` directory in vault)

Run `obsidian help` for the full command list (~100 commands, requires GUI running).
