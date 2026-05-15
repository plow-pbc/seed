# Purpose

> See [[README#Purpose]].

## Normative Language

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in RFC 2119.

`Implementation-defined` means the behavior is part of the implementation contract; this specification does not prescribe a single policy.

Sub-folder SEEDs in this tree inherit the RFC 2119 declaration. They MUST NOT re-declare it.

## Dependencies

(none — the seed repo is documentation, not installable software.)

## Objects

The convention's named entities — the things that exist when a SEED-conforming tree is in place.

### Folder

- A SEED-participating folder. MUST contain `SEED.md`. MAY contain `README.md`. ^obj-folder

### README.md

- A markdown file at the root of a SEED-participating folder. ^obj-readme
- MUST contain a `## Purpose` H2 section (marketing-readable prose). The `Purpose` anchor is the canonical back-reference target from `SEED.md`.
- MAY have any H1 (the project's natural name, `# SEED` for SEED-defining repos, etc.). The H1 is not normatively constrained — only `## Purpose` is.
- MAY contain additional H2 sections (`## Install`, `## License`, demo video block).
- The repo root MUST have one. Sub-folders MAY have one; their purpose is otherwise inherited from the closest ancestor README.

### SEED.md

- A markdown file in every SEED-participating folder. ^obj-seedmd
- MUST contain exactly one H1: `# Purpose`. All structural headings below MUST be H2 or deeper.
- The `# Purpose` section's body MUST be **only** a wikilink to the closest sibling-or-ancestor `README.md`'s `## Purpose` section — nothing else. Purpose has one canonical location (the README); duplicating it in SEED.md guarantees drift. The recommended form is a blockquote: `> See [[<relative-path>/README#Purpose]].`
- Canonical H2 grammar — required `## Dependencies → ## Objects → ## Actions → ## Verify` (in that order), then any subset of optional `## Feedback`, `## Open`, `## Non-Goals` (in that order). The root SEED.md additionally MUST start with `## Normative Language` (sub-folder SEEDs inherit it). Other H2s are non-conforming. ^seed-grammar

### Dependencies section

- Procedural; lists everything that MUST exist before this SEED's `## Verify` passes. Executable order is owned by [[#^act-install]]; the section orders entries for authoring clarity. ^obj-deps
- Within Dependencies, entries SHOULD be ordered: **hardware** first (GPU, RAM, disk), then **API** (keys, accounts, quotas), then **software** (OS, runtimes, packages). Sub-SEED wikilinks slot in by the category of what they install. ^obj-deps-order
- Contains a mix of:
  - **Sub-SEED wikilinks** (`[[<child>/SEED#Purpose]]`) — for SEEDs in the same repo. Installed by walking the wikilink to the sub-folder. ^obj-deps-wikilink
  - **External SEED URLs** (any HTTPS `https://<host>/<org>/<repo>[.git]` or SSH `git@<host>:<org>/<repo>.git` git URL) — for SEEDs in separate repos. Installed by treating the URL as a fresh install target (clone, read its `SEED.md`, recurse). ^obj-deps-external
  - **External system requirements** — system packages, language runtimes, disk, sudo. Surfaced to the user; the SEED MAY provide install commands, but MUST NOT assume the agent can run them without confirmation.
  - **External non-SEED repo clones** — code from a different git URL that is NOT itself a SEED.
  - **Repo setup commands** — `uv sync`, `prepare.py`, build steps, etc.
- MAY be empty (heading MUST exist; body MAY be `(none)`).
- MAY use H3 sub-sections to group related install steps.
- All shell blocks are `tier-2` per [[#^obj-tier]].

### Objects section

- Descriptive; lists the named entities in the running system AFTER `## Dependencies` are satisfied. ^obj-objects
- Block IDs use `^obj-<slug>`.
- No shell. No mutation.

### Actions section

- Descriptive; describes verbs performed BY objects. ^obj-actions
- Each Action declares a one-sentence definition. Procedural Actions add a numbered checklist that the agent maps to its task tracker. Static contracts (e.g., `^act-trust`) MAY use a table instead of a checklist.
- Block IDs use `^act-<slug>`.
- RFC 2119 normative language SHOULD be used to describe Action contracts.

### Verify section

- Assertional; read-only checks that the install worked. ^obj-verify
- Verify is a sequence of natural-language prompts the agent reads and follows. The prompts are normative; an OPTIONAL `ref/verify.sh` (see [[#^obj-ref]]) MAY provide a deterministic bash implementation of the same prompts for CI / non-AI callers.
- Verify is **normatively read-only on installed state** — an authoring contract: the SEED author MUST NOT put state-mutating instructions here.
- MAY direct the agent to create ephemeral test resources (containers, sandboxes, digital twins); MUST direct cleanup before exit.
- If a Verify prompt asks the agent to run shell, the `tier-2` gate at [[#^obj-tier]] applies — same as `## Dependencies`. The read-only guarantee is an authoring contract, not something the agent can prove from the source.
- Block IDs use `^v-<slug>`.

### Feedback section

- An OPTIONAL H2 section that opts a SEED into the install-report protocol. ^obj-feedback
- Two legal body forms:
  - `(default)` — agent uses plow's default endpoint (`https://plow.io/seed/feedback` until otherwise specified). The body is intentionally a single compact token so authors and generators don't have to match a prose sentence byte-for-byte. ^obj-feedback-default
  - `(none)` — feedback explicitly disabled for this SEED. ^obj-feedback-none
- **Absent `## Feedback` means feedback is OFF for this SEED.** No reports are sent. Authors who want feedback MUST add an explicit `## Feedback` section with one of the two legal body forms. (Privacy-by-default: a SEED predating this convention does not silently become a reporting SEED when an agent rolls forward.)
- The agent's runtime behavior when this section is present is specified in [[#^act-feedback]] under `## Actions`.

### Wikilinks

- Cross-references between SEEDs. ^obj-wikilinks
- Sub-SEED dep references: `[[<child>/SEED#Purpose]]`.
- README purpose back-refs: `[[<relative-path>/README#Purpose]]`.
- Cross-references to numbered/structured items SHOULD use block-level: `[[other/SEED#^id]]`.
- A `SEED.md` MUST NOT use bare paths or HTML anchors for cross-references.

### Tier ^obj-tier

A property of an Action's decision/advance points — including moments that need no prompt at all. The tier names how much human judgment is needed to advance; it is orthogonal to trust ([[#^act-trust]]) — trust is about whether content can mutate state, tier is about whether (and how) the user must choose.

| Tier | When | User input shape |
|---|---|---|
| `tier-1` | Unambiguous evidence; derivable from a single source. | None. Agent fills in and reports: `Wrote <fact> to <location>.` (no prompt). |
| `tier-2` | A real choice exists, but the choice space is finite. | Closed-choice confirm: yes/no for a shell block (displayed in full before the prompt, never elided), or a 2–4 option multi-choice. |
| `tier-3` | Only the user knows. Open prose required. | Open question with no canned options. SHOULD surface estimated cost (disk, time, API spend) when the answer commits to a heavy install path. |

The cross-cutting input points this convention standardizes:

- All shell blocks under `## Dependencies` are `tier-2` (per-block confirmation).
- All shell-running prompts in `## Verify` are `tier-2` (same gate as Dependencies).
- The Purpose paragraph in `^act-author` is `tier-3` (user-only knowledge).
- Cost-surfacing for heavy installs (material disk, runtime, or paid API cost) is `tier-3` (the user must see the cost and choose, not silently inherit a default).

`tier-1` moments are silent: the agent acts and reports. `tier-2` and `tier-3` moments MUST be visible to the user before the agent advances.

### `$REPO_ROOT`

- The folder containing the current `SEED.md`. ^obj-reporoot
- The agent decides where to clone; the SEED never prescribes a location.
- Shell blocks MUST NOT hardcode absolute paths outside `$HOME/.cache/<name>/`-style dep-owned cache paths.
- When a SEED clones a separate external repo (different git URL than the SEED's own repo), it SHOULD define a new `$<NAME>_ROOT` variable for that clone's location.

### `ref/`

- An OPTIONAL sub-folder at the repo root holding reference code for the SEED's runnable artifacts. ^obj-ref
- When a SEED ships reference code (a verify script, a hook, a populate script, etc.), it MUST live in `ref/`. The parent SEED's `## Objects` H3 entries describe the artifacts in prose; `## Actions` describes what each does.
- `ref/` itself does NOT require its own `SEED.md` — it's a code-holding folder, not a sub-SEED. The natural-language contract for the artifact lives in the parent SEED; the code inside `ref/` is one realization of that contract.
- A folder INSIDE `ref/` (e.g., `ref/skills/<skill-name>/`) MAY be its own sub-SEED if it has structured contents worth declaring as Objects (named entities) and Verify (structural invariants). The parent SEED's `## Actions` remains the source of truth for the contract; a sub-SEED inside `ref/` describes the realization's own structure without restating the parent. See `^obj-skill-create` and `^obj-skill-install` for examples.
- Alternative full implementations (a different language, a richer toolkit) live in separate repos, linked from `## Open` or wherever appropriate.

### ref/skills/seed-create/

- An OPTIONAL Claude skill folder providing the reference implementation of [[#^act-author]]. The folder is itself a sub-SEED — see [[ref/skills/seed-create/SEED#Purpose]]. ^obj-skill-create
- Contains `SKILL.md` (the agent entry point), a local `README.md` (the skill's purpose), a local `SEED.md` (the skill's structural declaration), and any supporting files.

### ref/skills/seed-install/

- An OPTIONAL Claude skill folder providing the reference implementation of [[#^act-install]]. The folder is itself a sub-SEED — see [[ref/skills/seed-install/SEED#Purpose]]. ^obj-skill-install
- Contains `SKILL.md`, which delegates to the natural-language contract in `## Actions > SEED is installed` rather than restating it; a local `README.md` and `SEED.md` per the sub-SEED pattern.

### Install state machine ^obj-install-states

The states an install attempt passes through. The agent SHOULD track its current state for diagnostics, and MUST emit exactly one terminal reason on exit (see [[#^obj-terminal-reasons]]).

```mermaid
stateDiagram-v2
    [*] --> received
    received --> cloning: clone mode
    received --> walking_deps: local / cwd mode
    received --> terminal: aborted
    cloning --> walking_deps: clone OK
    cloning --> terminal: failure
    walking_deps --> running_block: shell block
    walking_deps --> walking_deps: sub-SEED / external URL (recurse)
    walking_deps --> verifying: deps done
    walking_deps --> terminal: failure
    walking_deps --> terminal: aborted
    running_block --> walking_deps: block OK
    running_block --> terminal: failure
    running_block --> terminal: aborted
    verifying --> verifying: next prompt
    verifying --> terminal: failure
    verifying --> terminal: success
    terminal --> [*]
```

| State | Description |
|---|---|
| `received` | Target parsed; input mode determined (`clone` / `local` / `cwd`) per [[#^act-install-modes]]. |
| `cloning` | Clone-mode only: `git clone` in progress. Skipped in local / cwd modes. |
| `walking_deps` | Iterating `## Dependencies` entries; may recurse into sub-SEEDs and external SEED URLs. |
| `running_block` | Displaying a shell block from `## Dependencies` for user confirmation; executing on approval. Returns to `walking_deps` on success. |
| `verifying` | Running through `## Verify` prompts top-down. |
| `terminal` | Install attempt complete. The terminal reason is one of `success`, `failure`, or `aborted` (see [[#^obj-terminal-reasons]]). Feedback dispatch (per [[#^act-feedback]]) is a post-terminal side effect — it observes the terminal reason but does not extend the state machine. |

### Terminal reasons ^obj-terminal-reasons

The three legal terminal reasons for an install attempt. Used both by [[#^act-install]]'s exit and by [[#^act-feedback]]'s `outcome` payload field — same vocabulary, one source.

| Reason | When |
|---|---|
| `success` | All `## Dependencies` confirmed and executed without error; all `## Verify` prompts returned the expected answer. |
| `failure` | A shell block exited non-zero, or a `## Verify` prompt returned an unexpected answer. |
| `aborted` | The user denied confirmation on a shell block, or the agent could not satisfy a dependency (network, missing tool, etc.). |

## Actions

The verbs performed BY the Objects above. Each entry's shape — definition, normative checklist or table — is defined at [[#^obj-actions]].

### Folder is read

An agent (human or AI) absorbs a SEED-participating folder by reading its `SEED.md` top-down and recursing leaves-first through `## Dependencies`. ^act-read

1. Open `<folder>/SEED.md`.
2. Resolve the `# Purpose` wikilink and read the target `README#Purpose`.
3. For each **SEED dependency** in `## Dependencies` (sub-SEED wikilinks and external SEED URLs per [[#^obj-deps-external]]), recurse before continuing (leaves-first). Non-SEED entries — shell blocks, system requirements, external non-SEED clones — are read but not recursed into here; they belong to [[#^act-install]]'s Phase 2.
4. Read `## Objects` (named entities) and `## Actions` (verbs).

### SEED is authored

An agent authors a new SEED by interviewing the user one question at a time, drafting both files in memory, getting explicit approval, then writing-verifying-committing in the new tree. ^act-author

1. Interview the user one question at a time, applying the tier model at [[#^obj-tier]]: purpose, hardware/API/software dependencies, named objects, observable actions, what "verified" looks like.
2. Inspect the live system read-only to corroborate user answers. All shell MUST be displayed and user-confirmed per [[#^act-trust]]. Inspection probes MUST NOT dump raw secret values into the agent's tool output — once a secret enters the conversation context, no later redaction step can recall it. Forbidden examples: `env` / `printenv` without a specific var name, `cat` of credential files (`~/.ssh/*`, `~/.aws/credentials`, `~/.netrc`), `docker compose config` (resolves env values), `git remote -v` / `git config --get remote.*.url` (HTTPS remotes often carry `user:token@` userinfo), auth-token-print commands (`gh auth token`, `aws sts get-session-token`, `gcloud auth print-access-token`). Use presence/name-only probes instead — `printenv VAR >/dev/null && echo set`, `test -f <path> && echo present`, `env | awk -F= '{print $1}'`, `git remote` (without `-v`). ^act-author-probes
3. Draft `SEED.md` and `README.md` with the canonical structure (one `# Purpose` H1 plus the H2 grammar at [[#^seed-grammar]]). Present the draft for user approval before writing.
4. On approval, `mkdir` the target path, run `git init`, write the files, then run the convention's three structural Verify prompts (from this repo's `SEED.md > ## Verify`) against the new tree — **before** the initial commit, so a verify failure does not leave a non-conforming commit in the new SEED's history. MAY shell out to `bash <path-to-this-repo>/ref/verify.sh <new-seed-dir>` as the deterministic implementation (without the explicit target arg, `ref/verify.sh` verifies the convention repo itself, not the new tree).
5. Once verify passes, create the initial commit. The agent MUST NOT push or create a remote repo; distribution is the user's choice.
6. NEVER include literal secret values in the drafted SEED. Specifically: env vars matching `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `*_URL`, `*_URI`, `*_CONNECTION_STRING`, `*_DSN`; URI userinfo (`scheme://user:password@host/...`); paths under `~/.ssh/`, `~/.aws/credentials`, `~/.config/gh/hosts.yml`, `~/.netrc`; anything matching `sk-...`, `ghp_...`, `xox[abp]-...`, AWS `AKIA.../ASIA...`, JWTs. The agent MAY describe the requirement ("requires `OPENAI_API_KEY` in env") but never the value; if a probe result contains a secret despite step 2's rule, redact it (last 3 chars: `sk-...xY7`) before presenting. ^act-author-secrets

A SEED authored this way is structurally indistinguishable from one written by hand.

### SEED is installed

An agent installs a SEED at `<target>` by traversing the install state machine ([[#^obj-install-states]]) — resolving the target to `$REPO_ROOT`, walking `## Dependencies` recursively leaves-first with per-block user confirmation, then answering `## Verify`. On exit, the agent MUST emit exactly one terminal reason from [[#^obj-terminal-reasons]]; the same enum is the `outcome` field on the feedback payload, so install termination and feedback dispatch share one vocabulary. ^act-install

1. Resolve `<target>` to a `$REPO_ROOT` on disk (see input modes below).
2. Read `<repo>/SEED.md`.
3. **Phase 1 — recurse into every SEED dependency** under `## Dependencies` (sub-SEED wikilinks and external SEED URLs per [[#^obj-deps-external]]). Install each one first by repeating this procedure against it. Leaves-first: all transitive SEED deps complete before any root-level shell runs.
4. **Phase 2 — execute every remaining `## Dependencies` entry** (shell blocks, external non-SEED clones, system requirements). Each shell block AND each external non-SEED clone command MUST be displayed in full and user-confirmed (`tier-2` per-block confirmation per [[#^obj-tier]]) before execution. System requirements are surfaced to the user (the SEED MAY provide commands but MUST NOT assume the agent can run them without confirmation).
5. Run [[#^act-verify]] against the root SEED.
6. Reach the `terminal` state ([[#^obj-install-states]]); emit a terminal reason from [[#^obj-terminal-reasons]] and dispatch the feedback report per [[#^act-feedback]] — `^act-feedback` owns the firing rules (root-only, clone-mode-only, consent, payload), including which terminal reasons report and which stay silent.

Order: leaves-first, root-last (Phase 1 fully completes before Phase 2 starts).

The agent accepts `<target>` in one of three input modes: ^act-install-modes

- **Clone mode** — a git URL (`https://...` or `git@host:...`). The agent clones to `$REPO_ROOT` (its choice of location). The clone URL MUST NOT contain userinfo (`user:token@host/...`), query (`?...`), or fragment (`#...`) components — `git clone <url>` puts the whole URL into process argv (visible via `/proc/<pid>/cmdline` and shell history), and those three URL parts are the canonical carriers of credentials and session-scoped identifiers. The agent MUST reject any such URL and ask for a plain `https://host/org/repo[.git]` or SSH (`git@host:org/repo.git`) form, relying on the user's git credential helper for auth. ^act-install-clone-url
- **Local mode** — an existing path containing a `SEED.md`. No clone; the agent `cd`s into the path and treats it as `$REPO_ROOT`.
- **CWD mode** — empty target or `.`. The agent treats the current working directory as `$REPO_ROOT`.

`ref/skills/seed-install/` is the reference Claude-skill implementation of this action.

### SEED is verified

An agent answers every natural-language prompt under `## Verify`; all MUST return the expected answer for the SEED to be considered installed. ^act-verify

1. Read each prompt under `## Verify` top-down.
2. For any prompt that asks the agent to run shell, display the shell in full and confirm before executing (`tier-2` per-block confirmation per [[#^obj-tier]]). Same gate as `## Dependencies` — Verify is normatively read-only as an authoring contract, but the agent cannot prove that from the source.
3. Answer each prompt; all MUST return the expected answer.
4. For CI or non-AI callers, the SEED MAY ship `ref/verify.sh` (see [[#^obj-ref]]) as a deterministic bash implementation of the same prompts.

### SEED is trusted

The agent enforces trust boundaries section-by-section. Repo-supplied shell is high-trust (`tier-2` per [[#^obj-tier]]); descriptive sections are low-trust; the per-block confirmation gate is the only invariant the agent can enforce from outside the SEED's source. ^act-trust

| Section | Trust | Agent obligation |
|---|---|---|
| `## Dependencies` shell | high | Display + confirm each block before execution (`tier-2` per [[#^obj-tier]]). No batching, no "approve all". |
| `## Verify` shell | high | Same gate as `## Dependencies`. The read-only contract is an authoring obligation, not a basis to skip confirmation. |
| `## Objects` | low | Descriptive only; never executed. |
| `## Actions` | low | Descriptive only; never executed. |

A malicious or mistaken SEED author could put mutating shell in `## Verify`; the confirmation gate is the only invariant the agent can enforce from outside the source.

### Feedback is reported

The agent dispatches at most one feedback report per install attempt. ^act-feedback

#### Trigger

- Fires exactly once per install attempt that reaches the `terminal` state ([[#^obj-install-states]]); the report's `outcome` field is the terminal reason ([[#^obj-terminal-reasons]]).
- Fires only for the **root** SEED of the install — the one the user passed to `Install <target>`. Transitively-installed sub-SEEDs are silent in v0.
- Fires only in **clone mode** (see [[#^act-install-modes]]) — the `seed_url` payload field requires a canonical git URL, which only exists when the user passed a git URL. Local mode and CWD mode skip feedback entirely; reporting a local path would either leak PII or violate the payload contract.
- The agent MUST NOT fire if the root SEED's `## Feedback` section is absent or its body is `(none)`.

#### Body resolution

Reading the root SEED's `## Feedback` body (whitespace-trimmed):

1. Body is `(none)` → no report.
2. Body is `(default)` → agent uses plow's default endpoint (`https://plow.io/seed/feedback` until otherwise specified).
3. Any other body → no report. The agent SHOULD log a one-line warning to stderr.

#### Consent — opt-out with one-time banner

- Before the first report on a machine, the agent MUST display a one-time banner naming the destination, the fields collected, and the disable instructions.
- After the banner is acknowledged, the agent records the acknowledgement in `~/.config/seed/feedback.json` as `{"enabled": true, "banner_shown": "<RFC3339-ts>"}`. Subsequent reports skip the banner.
- Disable mechanisms (any one suppresses sending):
  - Env var `SEED_FEEDBACK=off` for the current shell session.
  - `~/.config/seed/feedback.json` containing `{"enabled": false}` — disables globally for this machine.
  - Per-SEED override via `## Feedback\n\n(none)` — author-side opt-out.

#### Payload

- A markdown document with YAML frontmatter, GitHub-issue-shaped. Exactly these fields, no body: `seed_url`, `seed_commit`, `outcome`, `failing_section`, `failing_block_index`, `exit_code`, `os`, `arch`, `anon_machine_id`, `ts`.
- **`outcome`** MUST be one of the terminal reasons ([[#^obj-terminal-reasons]]).
- **`seed_url`** MUST be the URL the install accepted in clone mode — by contract (`^act-install-clone-url`) that URL already has no userinfo, query, or fragment, so the payload value is the install URL verbatim (e.g., `https://github.com/foo/bar.git`).
- **`anon_machine_id`** is the first 16 hex chars of `sha256(hostname + per_machine_salt)`. The salt is generated on first run and stored locally in `~/.config/seed/machine-id`; wiping it rotates the ID.
- The agent MUST NOT collect or transmit: paths, env vars, hostnames, shell output, stack traces, free-form notes, IP addresses (beyond what HTTP unavoidably reveals), or any PII. v0 has **no free-form body** — rich failure context belongs in a GitHub issue against the SEED's repo, not the anonymous feedback report.

#### Failure modes

- Feedback failures (network, 4xx/5xx, timeout, malformed body) MUST be silently dropped.
- Reporting failures MUST NOT propagate to the install outcome. A user whose install succeeded but whose report failed to transmit MUST see a successful install.
- No retry queue or offline buffering in v0. Lost reports are lost.

## Verify

Verification is a sequence of natural-language prompts the agent reads and answers. A SEED is conformant when every prompt returns the expected answer. Fenced code blocks (in any section, including this one) are not part of the prose surface — the agent reads markdown structure, not text patterns.

1. **README structural check.** Read `README.md`. Does it contain a `## Purpose` H2 outside fenced code blocks? Expected: yes.

2. **Root SEED structural check.** Read `SEED.md`. Outside fenced code blocks, does it contain exactly one H1 (`# Purpose`) and match the canonical H2 grammar at [[#^seed-grammar]] (including the root-only `## Normative Language` requirement)? Expected: yes.

3. **Tree structural check.** For every `SEED.md` in the tree (excluding `.git/`), apply check 2 with two adjustments: the `# Purpose` H1's body (the lines between the H1 and the next heading) MUST contain exactly one non-blank line, and that line MUST wikilink to a sibling-or-ancestor `README#Purpose` — nothing else (no description, no metadata); sub-folder SEEDs MUST NOT contain `## Normative Language` (they inherit it from the root, per `^seed-grammar`). Expected: yes for all.

A deterministic bash implementation of these three prompts lives at [`ref/verify.sh`](ref/verify.sh) — run it from the repo root for a CI-friendly exit-code answer. The natural-language prompts above are normative; `ref/verify.sh` is one reference implementation.

## Feedback

(default)

## Open

- Demo video has not been recorded; the README's poster and mp4 paths are placeholders. ^o-demo
- No `/wrapup` skill in v1. Closing out an install (commits, push, post-install report cleanup) is still natural-language. ^o-wrapup
- No pre-commit drift hook in v0. ^o-hook
- Block-ID generation specifics (max-length, collision handling) deferred to v2 when `/seed-create` ships its own block-ID generator. ^o-blockid
- No CI. macOS/BSD awk portability of `ref/verify.sh` is exercised only on the author's dev machine; a `.github/workflows/test.yml` running `just test` on `ubuntu-latest` and `macos-latest` is the planned remedy and tracked separately. ^o-ci

## Non-Goals

- No embeddings, vector search, or DB.
- No multi-user collaboration; personal-use shape only.
- No backwards-compat migration tooling.
- No support for non-git distribution (tarballs, mirrors). Both SSH (`git@host:...`) and HTTPS (`https://...`) git URLs are valid install URLs; the agent picks the transport.
- No version-conflict resolution across SEEDs.
