# gen-conventional-commits-message.md

- Generate a commit message in conventional commits format based on staged changes (`git diff --cached`)

- The requirement is to show the commit message only, NEVER git operations.

- Keep in your mind that the commit message will be shown in the release notes, so it should be clear and concise.

## Exclusions

Do NOT include:

- Phase/step numbers (e.g., "Phase 1", "Step 2")
- Plan or task references (e.g., "As part of...", "Following the plan...")
- Internal implementation context

Before outputting, verify the message contains none of the above.
