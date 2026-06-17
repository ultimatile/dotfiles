# Terminology discipline [contextual]

Term and notation choices that **split** (loanword handling, person-name spelling, new coinage) follow the project's glossary and an **ask-and-confirm gate** — never silent coinage. Contextual because it needs the project glossary and the conversation's confirmation history.

## General policy (this user's Japanese writing)

Priority for an English word:

1. Translate to Japanese; use the **established Japanese term** if one exists.
2. Otherwise **katakana**.
3. Keep the **original (English)** for technical terms that lose meaning when translated (e.g. `load-bearing`, the `thiserror` `reporter`).

Plus:

- **Person names always Latin full-spelling**, even inside an established compound (`Gauss分布`, `Hermite行列`, `Jacobi行列`), never katakana.
- Do **not coin** a "Name+noun" term when the concept is not established (e.g. no `Gauss行列` for "Gaussian matrix").

## Concern conditions

- A term needing a **new coinage** (not settled by the project glossary) was decided **silently** instead of proposed to the user.
- A **non-person-name loanword left in Latin** where an established **katakana** rendering exists (e.g. `allostasis` → `アロスタシス`). Keep the original English only as a last resort, when neither translation nor a natural katakana form serves (`load-bearing`, `reporter`).
- A person name rendered in **katakana** where the convention is Latin spelling.
- A bare `-ian` used for a matrix where the glossary assigns `Name行列` (e.g. `Jacobian` → `Jacobi行列`; `Gramian` per the project glossary's context split — linear-algebra matrix = `Gram行列`, control-theory `可制御/可観測Gramian` allowed).

## Delegation

The **authoritative term list is the project's glossary** (e.g. the Zenn repo `GLOSSARY.md`). This item carries only the general policy and the propose-and-ask mechanism. When the project has no glossary, propose the convention and confirm before adopting.

## N/A

No contested terminology introduced (no new loanword, person-name term, or coinage in the change).
