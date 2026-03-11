# gen-conventional-commits-message.md

- Generate commit message(s) in conventional commits format based on staged changes (`git diff --staged`)

- The requirement is to show the commit message(s) only, NEVER git operations.

- Keep in your mind that the commit message will be shown in the release notes, so it should be clear and concise.

## Granularity

- Analyze the staged diff and identify distinct logical changes (e.g., a bug fix and a new feature, or changes to different modules with independent purposes).
- If the staged changes contain **multiple logical changes**, generate a **separate commit message for each** in the order they should be committed.
- If splitting is recommended, note which files/hunks belong to each commit so the user can stage them separately via `git add -p` or per-file staging.
- When in doubt, prefer finer granularity over coarser.

## Type Selection

Choose the type based on **what was changed** and **why**:

1. First, identify the nature of the change:
   - Documentation only → `docs`
   - Build/CI configuration → `ci` or `build`
   - Code style/formatting → `style`
   - Tests only → `test`
   - Chores (deps, cleanup) → `chore`
   - Code restructuring without behavior change → `refactor`

2. For functional code changes, ask: "Did this functionality exist before?"
   - No, this is genuinely new → `feat`
   - Yes, but it was wrong/broken/non-compliant → `fix`

**Common mistakes to avoid:**

- BREAKING CHANGE does not imply `feat` — a spec-compliance fix can be `fix!`
- Large code changes do not imply `feat` — size is irrelevant
- API signature changes do not imply `feat` — if correcting a mistake, use `fix`

## Exclusions

Do NOT include:

- Phase/step numbers (e.g., "Phase 1", "Step 2")
- Plan or task references (e.g., "As part of...", "Following the plan...")
- Internal implementation context

Before outputting, verify the message contains none of the above.
