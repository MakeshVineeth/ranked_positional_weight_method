---
name: conventional-commit-pii-guard
description: Enforce Conventional Commits formatting and scan staged changes or repository files for PII, secrets, local user paths, and sensitive artifacts before publishing.
---

# Conventional Commit and PII Guard

Use this skill whenever preparing, validating, or creating a Git commit or publishing documentation and release artifacts.

## 1. Mandatory Pre-Commit PII and Secret Scan

Run the bundled scanner script before staging or committing:

```sh
python .agents/skills/conventional-commit-pii-guard/scripts/scan_pii.py --staged
```

To scan the full working tree of tracked and untracked non-ignored files:

```sh
python .agents/skills/conventional-commit-pii-guard/scripts/scan_pii.py --repo
```

Stop and clean up any flagged file before committing if the scanner exits non-zero. The scanner checks for:
- Sensitive filenames (`.env`, `key.properties`, `*.jks`, `*.keystore`, `*.pem`, `*.p12`, credential JSON files)
- Private key blocks and cloud or platform API tokens
- Local OS profile paths (`C:\Users\...`, `/Users/...`, `/home/...`)
- Personal email addresses, phone numbers, and government ID patterns

## 2. Conventional Commit Format

Write commit messages using the Conventional Commits 1.0.0 specification:

```text
<type>(<optional-scope>): <imperative subject>

<optional body explaining why the change was made>

<optional footer, e.g. BREAKING CHANGE: ...>
```

### Allowed Types
- `feat`: New user-facing capability or feature
- `fix`: Bug fix in domain logic, UI, or platform configuration
- `docs`: Changes to README, MkDocs, C4 diagrams, ADRs, or AGENTS guidelines
- `refactor`: Code restructuring that preserves external behavior
- `test`: Adding or updating unit or widget tests
- `build`: Gradle, AGP, Kotlin, pubspec, or dependency updates
- `ci`: Workflow or publishing automation updates
- `chore`: Repository maintenance and tooling updates

### Subject Rules
1. Use imperative, present-tense verbs (`add`, `fix`, `update`, `migrate`).
2. Keep the subject line at or under 72 characters.
3. Do not end the subject line with a period.
4. Keep prose plain and concise without em dashes or `--`.

## 3. Workflow Checklist
1. Stage intended changes: `git add <paths>`
2. Run `python .agents/skills/conventional-commit-pii-guard/scripts/scan_pii.py --staged`
3. Inspect `git status` and `git diff --cached --stat`
4. Commit using a validated Conventional Commit message.
