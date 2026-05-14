---
name: seed-create
description: Use when the user wants to capture a capability on their system as a SEED-conforming repo. Conducts a reconnaissance-then-interview flow, drafts SEED.md and README.md, creates a new directory with git init.
---

# Authoring a SEED

Reference implementation of the natural-language contract at [[../../../SEED#^act-author]].

## Hard gate

NO file writes, NO `mkdir`, NO `git init` until the user has approved the drafted `SEED.md` + `README.md`. Drafts MAY be held in memory; nothing hits disk pre-approval.

## Checklist

Create one task per item (TaskCreate) and complete in order:

1. Establish what capability the user wants to capture.
2. Pick a name and target path.
3. Reconnaissance sweep — read-only probes, batch-confirmed, sequentially executed.
4. Tiered confirmation of derived facts.
5. Open-ended interview for the things only the user knows.
6. Present full draft of `SEED.md` + `README.md` for approval.
7. On approval: `mkdir`, write files, `git init`, structural self-verify, initial commit.
8. Print the path and suggested next steps. Do NOT push.

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

## Step 3 — Tiered confirmation

For each fact derived from the probes, choose the right tier:

**Tier 1 (auto-fill, no question):** Derivable, single source of truth. Write into the draft and emit a one-line rolling diff:

> Wrote `GPU: NVIDIA A100, ≥40GB VRAM` to `## Dependencies > hardware`. Override?

**Tier 2 (closed confirm):** Detectable but with a real choice. Ask a closed multi-choice question with 2–4 options:

> Found ollama v0.1.32 with llama3 + codellama loaded. Should the SEED require:
> (a) both, pinned to current versions
> (b) llama3 only
> (c) any ollama model, no specific version

**Tier 3 (open question):** Only the user knows. Ask in prose. Reserve for:

- The Purpose paragraph for the README (intent, not state).
- The natural name of objects/actions in the running system.
- Sub-SEED decomposition decisions.
- Which observable failures matter most for `## Verify`.
- Feedback opt-in (`(default)` / `(none)` / absent).

## Step 4 — Draft `SEED.md` + `README.md`

Draft `SEED.md` directly against the canonical schema in [[../../../SEED#^obj-seedmd]] (one `# Purpose` H1 whose body is only a wikilink to `README#Purpose`; H2 sequence per the schema; `## Dependencies` ordered per [[../../../SEED#^obj-deps-order]]; `## Verify` is natural-language prompts per [[../../../SEED#^obj-verify]]). Do not transcribe the schema into this skill — read the parent contract, follow it, fail loudly if anything in the draft would disagree with it. This is the single source of truth: when the convention changes, the draft changes with it.

Draft `README.md` to this short shape (the convention is mostly free-form here):

```markdown
# <Capability Name>

## Purpose

<one-paragraph user-written prose: what is it, why does it exist>

## License

<user-chosen — default MIT>
```

No `## Install` in the draft — the install URL doesn't exist until after Step 9's `gh repo create` + push, so a placeholder committed now ships as broken instructions. The user MAY add `## Install` after publishing.

Present both files to the user *in full* and ask:

> Here's the draft. Approve to write to disk, or request changes.

Loop on edits until approved. No disk writes during the draft loop.

## Step 5 — Sub-SEED handling

If the user names sub-capabilities that warrant their own SEED, add one TODO bullet per sub-capability to the draft's `## Open` (e.g. `- TODO: author <child>/SEED.md ^o-<slug>`). Do NOT scaffold the child directory or interview for it in this run — recursive authoring is an explicit non-goal for v1 (see this skill's `## Non-Goals`).

## Step 6 — Secrets discipline

During reconnaissance and drafting, NEVER include literal secret values in any drafted file. Specifically:

- Env vars matching `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `*_URL`, `*_URI`, `*_CONNECTION_STRING`, `*_DSN` (connection-string env vars often embed credentials in userinfo).
- URI userinfo — any URL value of the form `scheme://user:password@host/...`. Strip the `user:password@` segment before showing or storing. `docker compose config` and similar reconnaissance probes routinely print these.
- Paths under `~/.ssh/`, `~/.aws/credentials`, `~/.config/gh/hosts.yml`, `~/.netrc`.
- Anything matching `sk-...`, `ghp_...`, `xox[abp]-...`, AWS `AKIA.../ASIA...`, JWTs.

If the capability requires a secret, the SEED MAY describe the requirement ("requires `OPENAI_API_KEY` in env", "requires `DATABASE_URL` in env") but MUST NOT show the value. If a probe result contains a secret, redact it (show only the last 3 chars: `sk-...xY7`) before presenting to the user. For env vars whose names alone could leak structure (e.g. internal hostnames), summarize as a count and category rather than verbatim.

## Step 7 — Write, verify, commit

After draft approval, run each block with user confirmation. Writes are NOT batched the way read-only probes were — each shell block displays and confirms individually. The target path MUST NOT already exist; `mkdir` (without `-p`) is intentional so an existing directory fails the run loudly rather than silently committing unrelated contents on top.

Verify the convention's three structural checks against the new tree **before** `git commit` — a failed verify means structural drift in the draft, and committing first leaves a non-conforming initial commit in the new SEED's history. The skill MAY shell out to this repo's `ref/verify.sh`, passing the new SEED's directory as an explicit target arg (without the arg, `ref/verify.sh` verifies the convention repo itself, not the new SEED):

```bash
mkdir -- "<target-path>"
cd -- "<target-path>"
git init
# Write SEED.md, README.md, and (only if the user requested it) ref/verify.sh
bash "<path-to-this-repo>/ref/verify.sh" "<target-path>"
git add .
git commit -m "feat: bootstrap SEED for <capability>"
```

On verify fail, surface the specific failure and offer to amend the draft (which loops back to Step 4's draft-approval gate); the directory and `git init` stay in place, the files are rewritten on the next pass, and `git commit` only runs once verify passes.

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
