# Rhetorical restraint in Japanese prose [mechanical]

LLM-drafted Japanese prose (Opus especially) fails by **form-excess, not vocabulary**. The "やばさ" lives in rhetoric and typography — bold saturation, em-dashes, aphoristic framing, parallelism — not in word choice. Derived from a published-human vs Opus corpus contrast where positives score ~0 on each signal and the Opus cluster scores high.

The author's blindspot for their own rhetoric is strong, so this is a **literal-text** audit. Detect form-excess; do **not** police vocabulary, punctuation, or register (those are separate concerns or non-concerns — see Anti-rules).

## Scope

This item targets **article / post prose** (the Zenn articles). Reference and spec documents — this skill's own files, `CLAUDE.md`, `GLOSSARY.md`, item definitions — legitimately use documentation-label bold (`**term**:` list labels) and structural separators, and are NOT held to the article-prose signals (R2 label-bold, em-dash-as-separator). Even there, prefer clean punctuation over rhetorical em-dashes, but a `**label**:` documentation list is not a concern. The high-signal tics (aphoristic framing, slogan headings, compulsive concept-gloss, clause-level bold-as-emphasis) remain concerns in any register.

## Concern conditions

- **Em-dash「—」in prose (R1)** — highest-precision single signal; human positives use it literally 0 times. Any rhetorical「—」/「——」(inserted clause, or a reveal「……——断定。」) is a concern.
- **Bold excess (R2)** — bold wrapping a full clause/sentence, `**語**:`-style bold-colon list headings, or bold saturation (many `**…**` per paragraph). NOTE: bold on a single term is normal; the concern is **clause-level bold and saturation**, not term emphasis.
- **Italic `*…*` (R2b)** — Japanese has no italic-emphasis convention, so `*…*` wrapping **Japanese** text is essentially never warranted → concern. Applying italic to **English** words is grammatically permissible but rarely warranted (flag only when gratuitous). EXCEPTION: the markdown image-caption idiom (`*キャプション*` on the line immediately after an image) is caption syntax, not italic emphasis → not a concern.
- **Aphoristic closers / meta-commentary (R3)** — 主張を先に置く / 一語に畳める / 核心は…だ / 煎じ詰めれば / 要するに / 身も蓋もない / に他ならない / に集約される, and bold 体言止め "decision sentences" ending sections.
- **Rhetoric structure (R4)** — chiasmus「Xを終わらせた装置がXを再生産する」, triadic climax「AならX、BならY、CならZ」, repetition-with-variation「Xも、Yも、根は一つ」.
- **Compulsive gloss (R5)** — Japanese concept + one English word in parens (注意（attention）, 観測可能性（observability）). Distinguish from **legitimate reference gloss**: if deleting the paren drops referenceability (error code, version, citation, standard-acronym first use) → legit; if it only appends an English synonym → concern.
- **Slogan headings (R6)** — headings that are rhetorical sentences (「夢を見られない知識システム」) instead of content nouns (「Fubini-Study計量」).
- **Grand opener (R7)** — opening on an abstraction / thesis announcement rather than the concrete subject, problem, or anecdote.
- **Rhetoric-first (R8)** — sections that advance a metaphor chain instead of delivering a checkable artifact (code / math / command / repro).
- **Process-narration leak (R9)** — sentences that narrate the *act of writing* instead of delivering content: 本稿の主張を先に置きます / まず〜します / ここで〜しておきます / 最初に(あらかじめ)断っておくと / 〜を(表に)まとめておきます / 〜を述べておきます. This is a **context/register mismatch, not bad writing per se**: announcing intent before acting is a functional generation practice (autoregressive self-conditioning — placing "I will state X" raises the probability the continuation actually states X) and a legitimate assistant/agentic move (CoT preamble, task-plan announcing). It is a concern **only when it leaks onto a public writing surface** (finished reader-facing prose), where it is vestigial production scaffolding: the scaffold was needed to build the text but should not ship in it. Strip the scaffold; do **not** forbid narration in its native register (thinking blocks, task preambles). Because the generating author cannot see its own scaffold (the tic originates from *how* the text was produced), this is a prime **cold-reader / fresh-context** check — the drafter does not reliably self-catch it.
- **Manufactured / redundant reveal (R10)** — withholding a payload to disclose it for drama: 実は… / 正確な先例があります / 核心はここだ / 答えは〜だ / それは〜です, setting up a one-beat payoff. The high-severity sub-case is **redundant reveal**: the payload (the term, name, claim, or conclusion) was **already stated earlier in the same draft**, so the "reveal" re-discloses known information as if it were new — 勿体ぶり to a reader who already holds it (e.g. an intro that already says "X だと言われた", then a later section closing with "正確な先例があります。X です。"). Distinguish from **reader-navigation forward reference** (「次節で詳説する」, keep) — the concern is dramatized *disclosure*, not a pointer. Default to plain placement: state the key term/conclusion straight, without the withhold-then-disclose beat. Like R9 this is a **cold-reader / whole-draft** check: the redundancy is invisible at the local line and only surfaces when the same payload is spotted earlier in the text.

## Anti-rules (do NOT flag — false-positive guards)

- Do **not** police connectives (また / さらに / つまり / しかし / のである / ただし / すなわち / 例えば) — verified zero discriminating power; positives use them as much or more.
- Do **not** normalize punctuation (`、。` vs `，．`) — author choice.
- Do **not** force register (敬体/常体) — that is `register-consistency`, a separate item.
- Do **not** flag short sentences or smooth cadence alone — false-positive source (good human articles are smooth). Require R1–R4 to actually fire.
- Do **not** ban community-standard terms or legitimate English technical terms.
- Do **not** flag reader-navigation signposting (以下では〜を順に見る / 本稿では〜をたどる / この節では〜を扱う) as R9. Orienting the reader to what follows is content. The R9 concern is narration of the **author's own act** (これからXを述べます / しておきます / 断っておく), which is contentless scaffolding. Discriminator: does the sentence tell the reader *what is coming* (keep) or announce that the author is *about to perform a writing move* (cut)?

## Mechanical detection

Strip code blocks, inline code, and math (`$`/`$$`) before counting prose signals.

```sh
rg -n '—' "$f"                                      # R1: any em-dash in prose = concern
rg -o '\*\*' "$f" | wc -l                           # R2: bold density (pairs = count/2); triage clause-vs-term by reading
rg -n '^\s*[-*]\s*\*\*[^*]+\*\*\s*[:：]' "$f"        # R2: bold-colon list headings
rg -n '(^|[^*])\*[^*\s][^*]*\*([^*]|$)' "$f"         # R2b: italic *…* (exclude **bold**/list *; image-caption line exempt)
rg -n '（[^）]*[A-Za-z][^）]*）' "$f"                # R5: concept+English gloss (triage legit-reference by reading)
rg -n '主張を先に置く|一語に畳める|煎じ詰め|身も蓋もない|に他ならない|に集約' "$f"   # R3
rg -n '先に(置き|述べ)|ておきます|ておこう|断っておく|本稿の(主張|結論)を先に' "$f"   # R9: process-narration leak (read-triage; reader-navigation signposting is exempt)
rg -n '実は|正確な(先例|例)|核心は(ここ|これ)|答えは|それは.{0,24}(です|だ)。' "$f"   # R10: reveal-frame; then check the payload term recurs in an EARLIER section → redundant reveal
```

An em-dash hit is **always** a concern. The others need read-triage per the concern conditions (term-bold and reference-gloss are legitimate and must not be auto-failed). R9 and R10 in particular are the cold reader's job — the drafter is blind to its own scaffold (R9) and to drama it manufactured (R10). For an R10 reveal-frame hit, scan the **whole draft**: if the disclosed payload already appears in an earlier section, it is a redundant reveal (concern); a first and only disclosure is at most a style nudge toward plain placement.

## N/A

Non-prose surfaces (code, math, tables, frontmatter, bibliographic footnotes). A document with no added or modified Japanese prose.
