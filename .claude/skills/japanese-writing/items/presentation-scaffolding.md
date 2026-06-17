# Reader scaffolding & reference linking [contextual]

A **presentation** preference, distinct from `rhetoric-restraint` (which *removes* excess) — this *adds* what the reader needs to follow the text. Contextual: it requires judging a term's centrality to the article and the assumed reader's background.

## Concern conditions

- **First-mention OSS / tool without a link** — the first time an OSS project, library, CLI, or tool is named, link to its **official GitHub repo or landing page** (e.g. `[lazygit](https://github.com/jesseduffield/lazygit)`).
- **Uncommon technical term, unexplained and unlinked** — a technical term that is not widely known but not worth an inline explanation should be **linked to an authoritative source** (Wikipedia, spec, official docs). Example: `SSOT` rendered as a Wikipedia link.
- **Core concept treated as a mere link** — when an uncommon term is the article's **central** concept, a link is not enough; **explain it properly**: what field it comes from, what it means, why it is notable or relevant. Example: if `アロスタシス` (allostasis) is the core of an essay, introduce it ("生理学の用語で、近年〜として注目されている …"), not just link it. Treatment **scales with centrality**: peripheral term → link suffices; central term → explain (and link).
- **Expert-only introduction** — a concept introduced assuming subfield expertise the intended reader lacks. Build it up with scaffolding so a competent non-specialist can follow. Counter-example (bad): a `std::vector<bool>` intro only a C++ expert parses. Better: introduce the mechanism step by step — "`std::vector<bool>` には特殊化があり、要素アクセスがプロキシ参照を返すため、参照で受け取ると非直感的な挙動になる…". Match explanation depth to the **assumed audience**, not to an expert.

## Rule-ification limits

First-mention-link and term-link are concrete and checkable. Centrality-scaling and audience-depth are **judgment calls** — there is no mechanical threshold; weigh the term's role and the article's stated audience. When unsure whether a term is "core enough to explain", err toward a one-sentence orientation over a bare link.

## N/A

No newly introduced OSS / tools or uncommon terms in the change; or a note whose stated audience genuinely is specialists (a deliberately advanced piece), where subfield expertise may be assumed.
