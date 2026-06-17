# Register (敬体/常体) consistency [mechanical]

Japanese politeness register must be **internally consistent within a document's prose**. The register choice itself is a per-article preference confirmed up front (SKILL.md preference gate), not a quality defect — the defect is *mixing within prose*.

## Modes

- **all敬体** — entire text 敬体 (です・ます).
- **all常体** — entire text 常体 (だ・である).
- **almost敬体** — prose is 敬体, but TL;DR-style **bullet lists may use 常体** for information density.

## Concern condition

Mixing 敬体 and 常体 in **地の文 (prose)**. Under `almost敬体`, 常体 in bullet lists is **sanctioned and NOT a concern**; 常体 leaking into prose sentences IS a concern.

Empirically, prose mixing was 0/20 in the reference corpus — this is a prevention guard, so a hit is noteworthy, not routine.

## Detection method

- Inspect **sentence-final predicates only** (immediately before `。` / `.` / `．`). 敬体 finals: です・ます・ました・ません・でしょう・ください. 常体 finals: だ・である・する・した・なる (断定). Both appearing in adjacent prose sentences / the same paragraph → concern.
- **Exclude**: code blocks, math (`$` / `$$`), footnote bibliographies, `:::message` / `:::details` / quote (`>`) blocks, headings and 体言止め fragments, and — under `almost敬体` — bullet-list items.
- Do **not** match subordinate-clause する / である (連体・連用 inside a sentence) — only sentence-final predicates, else false positives explode.
- Handle all three sentence terminators: `。` `.` `．`.
- Decide the document's majority register, then flag the minority occurrences that violate the chosen mode.

```sh
rg -n '(です|ます|ました|ません|でしょう|ください)[。.．]' "$f"   # 敬体 finals
rg -n '(だ|である|する|した|なる)[。.．]' "$f"                    # 常体 finals (filter subordinate by reading)
```

These are read-triage aids, not a hard gate.

## N/A

Documents with no Japanese prose (pure code / reference / data). A consistent single-register prose document is a **PASS** (the rule is satisfied), not N/A — N/A means the rule does not apply at all.
