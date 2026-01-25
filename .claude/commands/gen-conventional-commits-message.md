# gen-conventional-commits-message.md

- Generate a commit message in conventional commits format based on staged changes (`git diff --staged`)

- The requirement is to show the commit message only, NEVER git operations.

- Keep in your mind that the commit message will be shown in the release notes, so it should be clear and concise.

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
