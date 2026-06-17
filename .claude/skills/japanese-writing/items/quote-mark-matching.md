# Quote-mark matching to the quoted content [mechanical]

Quotation marks must **match what is being quoted**, not the surrounding prose. Japanese 「」 is for quoting Japanese words/phrases/paraphrases. A verbatim foreign-language string or a code token is not Japanese prose — wrapping it in 「」 mis-signals that it is a Japanese expression, and (for code) loses the monospace affordance a reader uses to spot a literal.

This is a surface instance of the audience/content-boundary principle: the delimiter advertises the *kind* of the enclosed content, so it has to track the content, not the author's default punctuation.

## Concern conditions

- **Verbatim foreign-language string in 「」** — an English (or other non-Japanese) string quoted *as the literal text it is* (an error message, a UI label, a quoted sentence) wrapped in 「」 → should be `"..."`. Example: 「Your tool call was malformed and could not be parsed.」 → `"Your tool call was malformed and could not be parsed."`
- **Code / identifier / system-prompt string in 「」** — a code token, identifier, path, flag, or verbatim system-prompt string in 「」 → should be backticks `` `...` ``. Backticks also fit a verbatim foreign string that is *drawn from code/config/system text* (the user sanctioned backticks for a system-prompt error string).

## Anti-rules (do NOT flag)

- A **Japanese word, paraphrase, or coined label that merely contains an embedded loanword** is Japanese content → 「」 is correct. Discriminator: is the quoted span a Japanese expression (has Japanese morphology/particles, e.g. 「malformedだった」, 「パブリックなエラー型」) or a verbatim foreign/code literal? Only the latter is a concern.
- Do **not** convert 「」 around genuinely Japanese quoted speech or terms.
- Punctuation choice for Japanese prose (`、。` vs `，．`, and 「」 vs other Japanese quote styles) is a separate author-preference axis — not this item.

## Mechanical detection

```sh
rg -n '「[^」]*[A-Za-z][^」]*」' "$f"   # 「」 containing Latin letters → read-triage
```

A hit is **not** automatically a concern: triage by the Anti-rule discriminator. A 「」 span whose text is a Japanese expression with an embedded English word is fine; a 「」 span whose text is a verbatim English string or a code literal is the concern. Choose `"..."` for prose strings, backticks for code/identifier/system-prompt strings.

## N/A

No quoted foreign-language strings or code literals introduced in the change; or a document with no Japanese prose.
