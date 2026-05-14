---
name: seed-create
description: Use when the user wants to capture a capability on their system as a SEED-conforming repo. Conducts a reconnaissance-then-interview flow, drafts SEED.md and README.md, creates a new directory with git init.
---

# Authoring a SEED

Reference implementation of the natural-language contract at [[../../../SEED#^act-author]].

## Hard gate

NO file writes, NO `mkdir`, NO `git init` until the user has approved the drafted `SEED.md` + `README.md`. Drafts MAY be held in memory; nothing hits disk pre-approval.

## Checklist

Track one task per item in the agent's task tracker and complete in order:

1. Establish capability + target path (Step 1).
2. Reconnaissance probes — read-only, batch-confirmed, sequential (Step 2).
3. Confirm derived facts — auto-fill or ask (Step 3).
4. Draft `SEED.md` + `README.md` for approval (Step 4), folding in any sub-SEED TODOs to `## Open` (Step 5).
5. Write, structural self-verify, commit (Step 7).
6. Hand-off — print path + next steps. Do NOT push (Step 8).

Step 6 — secrets discipline — applies throughout reconnaissance and drafting, not as a separate task.

## Step 1 — Capability + target path

Ask the user, one question at a time:

- "What capability is this SEED capturing? (e.g., 'ollama + llama3 running locally', 'my dotfiles', 'this codebase')"
- "What's the natural name for the SEED's home directory?"
- "Where should it live?"

If the chosen path already exists, suggest `<path>2`, `<path>3`, etc.

## Step 2 — Reconnaissance sweep

Derive read-only probes from the capability name — cwd manifests, system info, hardware/tool versions, capability-specific status commands. Present the full probe list to the user as one batch:

> I'd like to run these N read-only probes. OK to run them all?
> 1. `which ollama`
> 2. `ollama list`
> 3. ...

On batch-approval, execute sequentially. If any probe isn't obviously read-only, split it out and confirm individually before running.

## Step 3 — Confirm derived facts

For each fact:

- **Auto-fill probe-derived facts** with a one-line rolling diff — e.g. `Wrote 'GPU: NVIDIA A100, ≥40GB VRAM' to ## Dependencies > hardware. Override?`
- **Ask the user** only when the agent is choosing policy (which versions to pin, what counts as a `## Verify` success, sub-SEED decomposition, feedback opt-in) or lacks the information (the Purpose paragraph, natural names for objects/actions). Prefer closed multi-choice for binary-ish picks; prose for open intent.

## Step 4 — Draft `SEED.md` + `README.md`

Draft `SEED.md` directly against the canonical schema in [[../../../SEED#^obj-seedmd]] and the linked Dependencies/Objects/Actions/Verify object rows. Do not transcribe the schema into this skill — read the parent contract, follow it, fail loudly if anything in the draft would disagree with it. This is the single source of truth: when the convention changes, the draft changes with it.

Draft `README.md` to this short shape (the convention is mostly free-form here):

```markdown
# <Capability Name>

## Purpose

<one-paragraph user-written prose: what is it, why does it exist>

## License

<user-chosen — default MIT>
```

No `## Install` in the draft — the install URL doesn't exist until after the user publishes the repo, so a placeholder committed now ships as broken instructions. The user MAY add `## Install` after publishing.

Present both files to the user *in full* and ask:

> Here's the draft. Approve to write to disk, or request changes.

Loop on edits until approved. No disk writes during the draft loop.

## Step 5 — Sub-SEED handling

If the user names sub-capabilities that warrant their own SEED, add one TODO bullet per sub-capability to the draft's `## Open` (e.g. `- TODO: author <child>/SEED.md ^o-<slug>`). Do NOT scaffold the child directory or interview for it in this run — recursive authoring is an explicit non-goal for v1 (see this skill's `## Non-Goals`).

## Step 6 — Secrets discipline

The two-boundary contract — probe transcript discipline and drafted-file discipline — lives in the parent SEED:

- Probe transcript: see [[../../../SEED#^act-author-probes]] for the forbidden-probe list and the presence/name-only alternatives.
- Drafted-file content: see [[../../../SEED#^act-author-secrets]] for the env-var / URI userinfo / credential-path / token-pattern bans.

Operationally, when an inspection probe surfaces a secret despite the parent rule (the user pasted output from somewhere else, a permitted probe returned more than expected, etc.), redact at the boundary before presenting to the user — show only the last 3 chars of the value (`sk-...xY7`). For env vars whose names alone could leak structure (e.g. internal hostnames), summarize as a count and category rather than verbatim.

## Step 7 — Write, verify, commit

After draft approval, run each block with user confirmation. Writes are NOT batched the way read-only probes were — each shell block displays and confirms individually. The target path MUST NOT already exist; `mkdir` (without `-p`) is intentional so an existing directory fails the run loudly rather than silently committing unrelated contents on top.

The user-supplied `<target-path>` is untrusted shell data. Pass it as an argv argument to `mkdir` / `cd` (never interpolated into a shell-quoted string), and use `--` to terminate flag parsing — same discipline `/seed-install` applies to user-supplied clone targets. The shell blocks below show the canonical form (`mkdir -- "$target_path"`, `cd -- "$target_path"`); when constructing the actual commands, bind `<target-path>` through the agent's argv/env mechanism rather than splicing the user's text into the rendered command string.

Verify the convention's three structural checks against the new tree **before** `git commit` — a failed verify means structural drift in the draft, and committing first leaves a non-conforming initial commit in the new SEED's history. The skill MAY shell out to this repo's `ref/verify.sh`, passing the new SEED's directory as an explicit target arg (without the arg, `ref/verify.sh` verifies the convention repo itself, not the new SEED).

**Bootstrap** — runs exactly once, on the first approval:

```bash
mkdir -- "$target_path"
cd -- "$target_path"
git init
```

**Write-verify-commit** — runs once per approved draft. After a verify failure, the next pass re-runs *only* this block; the bootstrap above is not repeated (`mkdir` would fail on the now-existing directory):

```bash
# (Re)write SEED.md, README.md, and (only if the user requested it) ref/verify.sh
bash "<path-to-this-repo>/ref/verify.sh" "$PWD"
git add .
git commit -m "feat: bootstrap SEED for <capability>"
```

On verify fail, surface the specific failure and offer to amend the draft (which loops back to Step 4's draft-approval gate). The directory and `git init` stay in place across retries; only the write-verify-commit block re-runs, and `git commit` only fires once verify passes.

## Step 8 — Hand-off

Print:

- Absolute path to the new SEED.
- The initial commit's hash.
- Suggested next steps: `gh repo create`, push, share the URL.

Do NOT run any of those steps yourself. Distribution is the user's call.

## Non-Goals for v1

- No editing of an existing SEED (use a fresh `/seed-create` or hand-edit).
- No sub-SEED authoring inside an existing tree (top-level only).
- No `gh repo create` or `git push`.
- No block-ID rules beyond plausible `^obj-*` / `^act-*` slugs; v2 formalizes collision and length.
- No parallel reconnaissance subagent dispatch (flagged for v1.1).
