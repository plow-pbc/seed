# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the spec-flavor contract for `/wrapup`: a Claude Code skill that updates `SEED.md` files at the end of a working session with what was learned.

## Components

- `SKILL.md` — the Claude Code skill file. ^obj-skillmd
- `wrapup.md` — OPTIONAL extended runbook. ^obj-runbook

## API

### Trigger

- `/wrapup` — typed by the user. The skill MUST be manual only; it MUST NOT auto-fire on session-end or any other event.

### Inputs

- Conversation context (the current Claude Code session: decisions made, invariants discovered, files touched).
- `git status --porcelain` and `git diff` across enclosing repos.
- Existing `SEED.md` files in the affected folders.

### Algorithm (MUST)

1. **Identify concepts** worth crystallizing from the conversation: decisions made, invariants discovered, components added, bugs found.
2. **For each concept, identify `target_files`**: the source files the concept describes.
3. **Route the concept to the closest enclosing `SEED.md`** whose folder covers all of `concept.target_files`. If no enclosing `SEED.md` exists, the skill MUST propose creating one before routing.
4. **Propose a delta** to that `SEED.md` (add to Components, Open, API, Dependencies — flavor-appropriate).
5. **Show diff per `SEED.md`.** The user confirms / edits / rejects per delta.
6. **Write files. The skill MUST NOT auto-commit.**

### Outputs

- Zero or more modified `SEED.md` files.
- A summary chat message describing what was crystallized and where.

### Errors

- The skill MUST NOT auto-commit.
- The skill MUST show diff before writing.
- The skill MUST NOT overwrite hand-written prose without explicit user confirmation.
- The skill MUST redact secrets to `…<last 3 chars>`.
- The skill MUST NOT write to a `SEED.md` that does not exist; if no enclosing SEED is found, the skill MUST propose creating one and route the concept there only after creation is confirmed.

## Install

Symlink-based; see [[../SEED#Install]].

## Verify

In a Claude Code session where files have been edited:

```
/wrapup
```

Expected:

- A diff is shown for each affected `SEED.md`.
- No `git commit` is created.
- Secrets are redacted to `…<last 3 chars>`.
- Cancellation leaves the tree unmodified.

## Non-Goals

- `/wrapup` MUST NOT auto-fire on session end.
- `/wrapup` MUST NOT run conflict resolution across parallel checkouts (deferred to v1).
- `/wrapup` MUST NOT write to non-`SEED.md` files.

## Open

- `SKILL.md` not yet written. ^o-skillmd
- Concept-routing heuristic (which folder claims a concept) not yet pinned. ^o-routing
- Chat-side summary format (post a chat summary vs rely on the diff) not yet decided. ^o-summary
^open
