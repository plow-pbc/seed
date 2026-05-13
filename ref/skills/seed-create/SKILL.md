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
7. On approval: `mkdir`, write files, `git init`, initial commit.
8. Self-verify against the SEED convention's three structural checks.
9. Print the path and suggested next steps. Do NOT push.

## Step 1 — Capability + target path

Ask the user, one question at a time:

- "What capability is this SEED capturing? (e.g., 'ollama + llama3 running locally', 'my dotfiles', 'this codebase')"
- "What's the natural name for the SEED's home directory?"
- "Where should it live? (default: `$HOME/Hacking/<name>/`)"

If the default path exists, suggest `<default>2`, `<default>3`, etc.

## Step 2 — Reconnaissance sweep

Based on the capability name, enumerate read-only probes from these families:

**Cwd / repo probes** (if the capability is "this repo" or a named codebase): `package.json`, `pyproject.toml`, `Cargo.toml`, `requirements.txt`, `Dockerfile`, `compose.yml`, `.python-version`, `.nvmrc`, `flake.nix`, `go.mod`, `Makefile`, `justfile`.

**System probes:**

- `uname -a`
- macOS: `sw_vers`, `system_profiler SPHardwareDataType`
- Linux: `lscpu`, `free -h`
- `nvidia-smi` (if GPU expected)
- `df -h ~`
- `which <relevant-tool>` and `<tool> --version` for each named tool

**Capability-specific probes** (derived from the capability name):

- "ollama + llama3" → `ollama list`, `ls ~/.ollama/models/`
- "postgres" → `pg_isready`, `psql --version`
- "docker compose stack" → `docker compose ps`, `docker compose config`
- Ask before adding probes that aren't obviously read-only.

Present the full probe list to the user as one batch:

> I'd like to run these N read-only probes. OK to run them all?
> 1. `which ollama`
> 2. `ollama list`
> 3. ...

On batch-approval, execute sequentially. If any probe in the batch isn't obviously read-only, split it out and confirm individually before running.

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

Use this canonical structure (matching the parent SEED.md's schema):

**`README.md`:**

```markdown
# <Capability Name>

## Purpose

<one-paragraph user-written prose: what is it, why does it exist>

## Install

Tell any AI agent:

> Install `<git-url-after-publish>`

## License

<user-chosen — default MIT>
```

**`SEED.md`:**

```markdown
# Purpose

> See [[README#Purpose]].

## Normative Language

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in RFC 2119.

## Dependencies

<ordered hardware → API → software, per parent SEED's ^obj-deps-order>

## Objects

<H3 entries with ^obj-* block IDs>

## Actions

<H3 entries with ^act-* block IDs>

## Verify

<numbered natural-language read-only checks>

## Feedback

<(default) or (none); omit section entirely to opt out>

## Open

<known incomplete items>

## Non-Goals

<explicit out-of-scope>
```

Present both files to the user *in full* and ask:

> Here's the draft. Approve to write to disk, or request changes.

Loop on edits until approved. No disk writes during the draft loop.

## Step 5 — Sub-SEED handling

If the user identified sub-capabilities that warrant their own SEED:

- Each sub-SEED gets its own subdirectory with its own `SEED.md`.
- The parent `## Dependencies` references each via `[[<child>/SEED#Purpose]]`.
- Order entries hardware → API → software (per `^obj-deps-order`).
- DO NOT recursively interview for the sub-SEED in this run. Add a top-level TODO bullet to the parent's `## Open` and let the user run `/seed-create` from inside the parent later. Recursive authoring is an explicit non-goal for v1.

## Step 6 — Secrets discipline

During reconnaissance and drafting, NEVER include literal secret values in any drafted file. Specifically:

- Env vars matching `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`.
- Paths under `~/.ssh/`, `~/.aws/credentials`, `~/.config/gh/hosts.yml`, `~/.netrc`.
- Anything matching `sk-...`, `ghp_...`, `xox[abp]-...`, AWS `AKIA.../ASIA...`, JWTs.

If the capability requires a secret, the SEED MAY describe the requirement ("requires `OPENAI_API_KEY` in env") but MUST NOT show the value. If a probe result contains a secret, redact it (show only the last 3 chars: `sk-...xY7`) before presenting to the user.

## Step 7 — Write + commit

After draft approval, run each block with user confirmation. Writes are NOT batched the way read-only probes were — each shell block displays and confirms individually:

```bash
mkdir -p <target-path>
cd <target-path>
git init
# Write SEED.md, README.md, and (only if the user requested it) ref/verify.sh
git add .
git commit -m "feat: bootstrap SEED for <capability>"
```

## Step 8 — Self-verify

Apply the three structural Verify prompts from [[../../../SEED#^obj-verify]] (the parent convention's `## Verify` section) to the new tree. The skill MAY shell out to this repo's `ref/verify.sh`:

```bash
bash <path-to-this-repo>/ref/verify.sh
```

Run with the new SEED's directory as cwd. Report pass/fail. On fail, the most likely cause is structural drift in the draft — surface the specific failure and offer to amend (which loops back to Step 4's draft-approval gate).

## Step 9 — Hand-off

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
