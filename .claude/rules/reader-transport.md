# Writing transports a third-party reader to grokking

When writing anything a human reads — docs, code comments, commit messages, issue bodies, PR descriptions, explanations in chat — the reader is a **third party who does not yet hold your conclusion**. The job of the writing is to **transport that reader from not-knowing to grokking**: to lay a path along which they reconstruct the conclusion and own it. It is NOT to state the conclusion, and NOT to mirror the requester's words.

Bad writing comes from writing to one of two people who **already share your frame**, which makes the transport step silently disappear:

1. **Author-vantage (your own eyes).** You write from the spot where you have already finished the inference. Symptoms:
   - **Assertion-as-established** — "X is correct", "this is the root cause", stated declaratively because you are certain. But your certainty does not transfer; a bare claim gives the reader no path to walk.
   - **Low self-explanatoriness** — the intermediate steps that are obvious *to you* get omitted, because from your vantage they need no saying. The reader, lacking them, cannot reconstruct the conclusion.
2. **Requester-vantage (the prompt-giver's eyes).** You anchor to whoever asked and reproduce their framing — sometimes verbatim. But a third-party reader does not have the requester's context, so echoing the requester's words transports no one but the requester.

Both failures collapse the reader into "someone who already shares the frame", so you skip building the path. The fix is not less confidence — it is to **give the reader what they need to arrive at the conviction themselves**: the steps, the evidence, the scaffold, in the order a not-yet-convinced mind needs them. Conviction is induced, not reported.

## Derived tests (what transport concretely requires)

These are the same principle on different surfaces; check them when drafting:

- **Purpose-relative selection.** Include a detail iff it is load-bearing for *this section's purpose* or *the reader's next action*. Accuracy is a constraint (don't write falsehoods), not the selection criterion — "true but irrelevant here" is noise and corrupts transport. Worked case: a README "セットアップ" section that described `npm install` only by the hook it wires (the thing being edited) was author-vantage; the reader at a setup gate needs the global effect (zenn-cli + all deps install). Contrast: in a hook-titled section, mentioning zenn-cli is noise *unless* it changes the reader's command.
- **Affordance isolation.** A runnable thing (a command) is a copy-paste affordance; a reader scanning for "what do I run" needs it as a standalone block at the same structural level as peer operations — not dissolved into prose. The author writing prose doesn't feel that need; the reader does.
- **Presentation scaffolding.** Put the footing a non-expert needs to follow (define the core term, link first-mention tools, don't presuppose expert context). This is the japanese-writing skill's `presentation-scaffolding` item — a surface implementation of this root.

## How to apply

Before shipping a piece of writing, read it back as the third-party reader who has *not* had this conversation and does *not* share your conclusion. Then run the diagnostic:

- **Did I assert where I should have shown a path?** Any "X is correct / is the root / clearly" that the reader has no way to verify from the surrounding text → replace the bare claim with the steps that earn it.
- **Did I omit what is obvious only to me?** Anything I left unsaid because *I* already inferred it → the reader hasn't; spell the link.
- **Did I echo the requester's framing instead of constructing understanding?** Verbatim reproduction of the prompt's words → rebuild it for someone without the prompt's context.

## Granularity guard

State this at the level of the failure *mechanism* (two frame-sharing vantages collapse the reader and skip the transport) and its *symptoms* (assertion-as-established, low self-explanatoriness, verbatim echo). "Just model the reader" / "induce grokking" alone is too abstract — it becomes a slogan that justifies all writing advice. The mechanism + symptoms is the grain that explains this case, the README selection case, and `presentation-scaffolding` without ballooning to cover all of rhetoric.

## Relationship to other rules

This is a **first-order writing principle**, orthogonal to `correction-handling.md` (which is the *meta* habit: on receiving a correction, ask "what principle is this an instance of?"). Following correction-handling is how this principle was named; it does not own it. The japanese-writing skill's `presentation-scaffolding` and `terminology-discipline` items are project-surface instances of this root.
