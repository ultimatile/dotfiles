---
name: japanese-writing
description: Write and review Japanese prose (articles, long-form docs) free of LLM rhetoric-excess, with consistent register and disciplined terminology. Universal layer — delegates project-specific house style to the project's CLAUDE.md / GLOSSARY.md. Use when drafting or reviewing Japanese articles, blog posts, or documentation prose.
---

# Japanese Writing

Universal quality rules for Japanese prose. Use when **writing or reviewing** Japanese articles, posts, or long-form docs.

Project-specific conventions (platform markdown syntax, frontmatter schema, house style, the term list) are **not** in this skill — they live in the project's `CLAUDE.md` / `GLOSSARY.md`, and this skill **delegates** to them. This skill carries only what is universal across the user's Japanese writing.

## Relationship to dev-skills (depends on, NOT integrated)

This skill is its own surface that **reuses** the `quality-list` machinery by reference; it does **not** add items to the universal `quality-list`.

- Its rules are **items** in `items/<slug>.md`, in the same format as `quality-list` items (H1 + lane tag, concern conditions, mechanical detection, N/A).
- It brackets writing with a **preflight** (à la `todo-check`) and an **audit** (à la `done-check`), reusing done-check's fresh-context-auditor pattern for the mechanical lane and `finding-triage` for ⚠ handling.
- Public-facing doc surfaces hand off to `file-pubdoc` (drafting) and the `quality-list` `public-doc-durability` item (audit). This skill governs prose register/rhetoric; those govern audience-boundary durability.

## Items

- [rhetoric-restraint](items/rhetoric-restraint.md) — mechanical
- [register-consistency](items/register-consistency.md) — mechanical
- [quote-mark-matching](items/quote-mark-matching.md) — mechanical
- [terminology-discipline](items/terminology-discipline.md) — contextual
- [presentation-scaffolding](items/presentation-scaffolding.md) — contextual

## Procedure

### 0. Load project house style

Read the project's `CLAUDE.md` and `GLOSSARY.md` if present (platform syntax, frontmatter, register modes, punctuation, term list). If absent, **corpus-learn**: read 2–3 accepted exemplars in the repo and match their conventions. Project house style wins over generic defaults for everything except the universal item rules below.

### 1. Preference gate (preflight) — confirm before writing

Split axes are **confirmed up front, never decided silently** (see `terminology-discipline` and `register-consistency`):

- **Register mode** — `all敬体` / `all常体` / `almost敬体` (prose 敬体 + 常体 allowed in TL;DR-style bullets for density).
- **Punctuation** — `、。` or `，．`.

Surface a single recommendation and get permission, e.g.:

> 「技術文書のため almost敬体・句読点は `、。` を推奨します。よろしいでしょうか？」

Lock the answer for the whole document. Then run the per-item preflight framing (what to set up so the audit passes): plan content-first sections, pre-confirm any term that would need a new coinage.

### 2. Write

Follow the locked preferences + the item rules + project house style. When a term needs a **new coinage** not settled by the project GLOSSARY, propose it and confirm (terminology-discipline) — do not invent silently.

### 3. Audit (done-check style) before declaring done

- **Mechanical lane** (`rhetoric-restraint`, `register-consistency`, `quote-mark-matching`): spawn a fresh-context `general-purpose` auditor that reads the item files + the draft and returns ✅ / ⚠ / ⊘ per item from **literal text only**, no author-intent speculation (same prompt shape as `done-check` Step 2). The author's blindspot for their own rhetoric is exactly what this neutralizes.
- **表記 lane (textlint, project-delegated)**: if the project provides a textlint setup (`.textlintrc*`), run it on the changed files (`npm run lint:text:fix`, or `npx textlint --fix <files>`) and ensure it passes before declaring done or committing. This mechanizes 表記ゆれ / 用字 (e.g. しくみ→仕組み via a prh dictionary) that LLM judgment does inconsistently. Fix until clean; do **not** bypass with `--no-verify`. The dictionary and config are the project's (`prh.yml` / `.textlintrc`), not this skill's — author-judgment cases the rule cannot mechanize (e.g. number kanji/arabic) are disabled there deliberately.
- **Contextual lane** (`terminology-discipline`, `presentation-scaffolding`): audit in main context against the project GLOSSARY, the ask-and-confirm history, and the article's intended audience.
- Triage each ⚠ per `finding-triage`; fix before declaring done. Hand any public-doc surface to `file-pubdoc` + `public-doc-durability`.

## Output format

Preflight (Step 1) and audit (Step 3) use the same table shape as `todo-check` / `done-check`: one row per item, `△ active / ⊘ N/A` (preflight) or `✅ / ⚠ / ⊘ N/A` (audit) with evidence.
