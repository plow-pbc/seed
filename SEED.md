# Purpose

> See [[README#Purpose]].

**Status:** v4 &middot; **Date:** 2026-05-11

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
- MUST contain `## Dependencies`, `## Objects`, `## Actions`, `## Verify` in that order.
- MAY contain `## Feedback` after `## Verify`, then `## Open` and/or `## Non-Goals` after that.

### Dependencies section

- Procedural; lists everything that MUST exist before this SEED's `## Verify` passes, in install order. ^obj-deps
- Contains a mix of:
  - **Sub-SEED wikilinks** (`[[<child>/SEED#Purpose]]`) — for SEEDs in the same repo. Installed by walking the wikilink to the sub-folder. ^obj-deps-wikilink
  - **External SEED URLs** (`https://github.com/<org>/<repo>` or `git@github.com:<org>/<repo>.git`) — for SEEDs in separate repos. Installed by treating the URL as a fresh install target (clone, read its `SEED.md`, recurse). ^obj-deps-external
  - **External system requirements** — system packages, language runtimes, disk, sudo. Surfaced to the user; the SEED MAY provide install commands, but MUST NOT assume the agent can run them without confirmation.
  - **External non-SEED repo clones** — code from a different git URL that is NOT itself a SEED.
  - **Repo setup commands** — `uv sync`, `prepare.py`, build steps, etc.
- MAY be empty (heading MUST exist; body MAY be `(none)`).
- MAY use H3 sub-sections to group related install steps.
- All shell blocks MUST be displayed to the user and explicitly confirmed before execution.

### Objects section

- Descriptive; lists the named entities in the running system AFTER `## Dependencies` are satisfied. ^obj-objects
- Block IDs use `^obj-<slug>`.
- No shell. No mutation.

### Actions section

- Descriptive; describes verbs performed BY objects. ^obj-actions
- Form: "Object X does Y when Z."
- Block IDs use `^act-<slug>`.
- RFC 2119 normative language SHOULD be used to describe Action contracts.

### Verify section

- Assertional; read-only checks that the install worked. ^obj-verify
- Verify is a sequence of natural-language prompts the agent reads and follows. The prompts are normative; an OPTIONAL `ref/verify.sh` (see [[#ref/]]) MAY provide a deterministic bash implementation of the same prompts for CI / non-AI callers.
- Verify is **normatively read-only on installed state** — an authoring contract: the SEED author MUST NOT put state-mutating instructions here.
- MAY direct the agent to create ephemeral test resources (containers, sandboxes, digital twins); MUST direct cleanup before exit.
- If a Verify prompt asks the agent to run shell, the agent MUST display the shell to the user and explicitly confirm before execution. Same trust gate as `## Dependencies` — the read-only guarantee is an authoring contract, not something the agent can prove from the source.
- Block IDs use `^v-<slug>`.

### Feedback section

- An OPTIONAL H2 section that opts a SEED into the install-report protocol. ^obj-feedback
- Two legal body forms:
  - `(default)` — agent uses plow's default endpoint (`https://plow.io/seed/feedback` until otherwise specified). The body is intentionally a single compact token so authors and generators don't have to match a prose sentence byte-for-byte. ^obj-feedback-default
  - `(none)` — feedback explicitly disabled for this SEED. ^obj-feedback-none
- **Absent `## Feedback` means feedback is OFF for this SEED.** No reports are sent. Authors who want feedback MUST add an explicit `## Feedback` section with one of the two legal body forms. (Privacy-by-default: a SEED predating this convention does not silently become a reporting SEED when an agent rolls forward.)
- The agent's runtime behavior when this section is present is specified in [[#Feedback is reported]] under `## Actions`.

### Wikilinks

- Cross-references between SEEDs. ^obj-wikilinks
- Sub-SEED dep references: `[[<child>/SEED#Purpose]]`.
- README purpose back-refs: `[[<relative-path>/README#Purpose]]`.
- Cross-references to numbered/structured items SHOULD use block-level: `[[other/SEED#^id]]`.
- A `SEED.md` MUST NOT use bare paths or HTML anchors for cross-references.

### `$REPO_ROOT`

- The folder containing the current `SEED.md`. ^obj-reporoot
- The agent decides where to clone; the SEED never prescribes a location.
- Shell blocks MUST NOT hardcode absolute paths outside `$HOME/.cache/<name>/`-style dep-owned cache paths.
- When a SEED clones a separate external repo (different git URL than the SEED's own repo), it SHOULD define a new `$<NAME>_ROOT` variable for that clone's location.

### `ref/`

- An OPTIONAL sub-folder at the repo root holding reference code for the SEED's runnable artifacts. ^obj-ref
- When a SEED ships reference code (a verify script, a hook, a populate script, etc.), it MUST live in `ref/`. The parent SEED's `## Objects` H3 entries describe the artifacts in prose; `## Actions` describes what each does.
- `ref/` itself does NOT require its own `SEED.md` — it's a code-holding folder, not a sub-SEED. The natural-language contract for the artifact lives in the parent SEED; the code inside `ref/` is one realization of that contract.
- Alternative full implementations (a different language, a richer toolkit) live in separate repos, linked from `## Open` or wherever appropriate.

## Actions

The verbs performed BY the Objects above.

### Folder is read

- An agent (human or AI) reads `<folder>/SEED.md` top-down. ^act-read
- The agent walks `## Dependencies` wikilinks recursively (leaves-first).
- The agent reads `## Objects` and `## Actions` to understand the system.

### SEED is installed

- An agent installs a SEED at `<url>` by: ^act-install
  1. Cloning (or fetching) `<url>` to `$REPO_ROOT` (agent's choice of location).
  2. Reading `<repo>/SEED.md`.
  3. For each SEED dependency in `## Dependencies` — either a `[[<child>/SEED#Purpose]]` wikilink (sub-folder SEED in the same repo) or an external SEED URL (`https://github.com/<org>/<repo>` or `git@github.com:<org>/<repo>.git`) — recursively installing that SEED first by repeating this procedure against it.
  4. Executing every shell block under `## Dependencies` (user-confirmed per block).
  5. Answering the `## Verify` prompts (user-confirmed for any shell each prompt asks the agent to run).
- Order: leaves-first, root-last.

### SEED is verified

- An agent reads the natural-language prompts under `## Verify` and answers each one. All MUST return the expected answer for the SEED to be considered installed. ^act-verify
- If a prompt asks the agent to run shell, the same per-block confirmation gate used for `## Dependencies` applies — the agent MUST display the shell to the user and confirm before execution. Verify is normatively read-only and idempotent (an authoring contract), but the agent has no way to prove read-only-ness from the source.
- For CI or non-AI callers, the SEED MAY ship `ref/verify.sh` (see [[#ref/]]) as a deterministic bash implementation of the same prompts.

### SEED is trusted

- The agent MUST treat all repo-supplied shell (`## Dependencies` and `## Verify`) as high-trust input requiring per-block user confirmation. ^act-trust
- The agent MUST treat `## Objects` and `## Actions` as low-trust (descriptive only; no side effects).
- The read-only contract on `## Verify` is an authoring obligation, not a basis for the agent to skip confirmation. A malicious or mistaken SEED author could put mutating shell in Verify; the confirmation gate is the only invariant the agent can enforce from outside the source.

### Feedback is reported

The agent dispatches at most one feedback report per install attempt. ^act-feedback

#### Trigger

- Fires exactly once per install attempt that reaches a terminal state (`success`, `failure`, or `aborted`).
- Fires only for the **root** SEED of the install — the one the user passed to `Install <url>`. Transitively-installed sub-SEEDs are silent in v0.
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
- **`seed_url`** MUST be the canonical repo URL with **userinfo, query, and fragment components stripped** (e.g., `https://github.com/foo/bar.git`, not `https://user:token@github.com/foo/bar.git?ref=branch#fragment`). If the install URL contains credentials, the agent MUST strip them before recording. Credential-bearing install URLs MUST NOT be transmitted in any form to the feedback endpoint.
- **`anon_machine_id`** is the first 16 hex chars of `sha256(hostname + per_machine_salt)`. The salt is generated on first run and stored locally in `~/.config/seed/machine-id`; wiping it rotates the ID.
- The agent MUST NOT collect or transmit: paths, env vars, hostnames, shell output, stack traces, free-form notes, IP addresses (beyond what HTTP unavoidably reveals), or any PII. v0 has **no free-form body** — rich failure context belongs in a GitHub issue against the SEED's repo, not the anonymous feedback report.

#### Failure modes

- Feedback failures (network, 4xx/5xx, timeout, malformed body) MUST be silently dropped.
- Reporting failures MUST NOT propagate to the install outcome. A user whose install succeeded but whose report failed to transmit MUST see a successful install.
- No retry queue or offline buffering in v0. Lost reports are lost.

## Verify

Verification is a sequence of natural-language prompts the agent reads and answers. A SEED is conformant when every prompt returns the expected answer. Fenced code blocks (in any section, including this one) are not part of the prose surface — the agent reads markdown structure, not text patterns.

1. **README structural check.** Read `README.md`. Does it contain a `## Purpose` H2 outside fenced code blocks? Expected: yes.

2. **Root SEED structural check.** Read `SEED.md`. Outside fenced code blocks, does it contain exactly one H1 (`# Purpose`), declare RFC 2119 in `## Normative Language`, and have the H2 sequence `## Dependencies → ## Objects → ## Actions → ## Verify` followed by any subset of `## Feedback`, `## Open`, `## Non-Goals` in that order? Expected: yes.

3. **Tree structural check.** For every `SEED.md` in the tree (excluding `.git/`), apply check 2 with two adjustments: the H1 MUST wikilink to a sibling-or-ancestor `README#Purpose` within the first three lines of the file, and sub-folder SEEDs MAY omit `## Normative Language` (inherited from the root). Expected: yes for all.

A deterministic bash implementation of these three prompts lives at [`ref/verify.sh`](ref/verify.sh) — run it from the repo root for a CI-friendly exit-code answer. The natural-language prompts above are normative; `ref/verify.sh` is one reference implementation.

## Feedback

(default)

## Open

- Demo video has not been recorded; the README's poster and mp4 paths are placeholders. ^o-demo
- No `/populate`, `/wrapup`, or `/install-seed` skill ships in v0. Installation is natural-language: tell any agent "Install <url>". ^o-skills
- No pre-commit drift hook in v0. ^o-hook
- Block-ID generation specifics (max-length, collision handling) deferred to v1 when `/populate` ships. ^o-blockid

## Non-Goals

- No embeddings, vector search, or DB.
- No multi-user collaboration; personal-use shape only.
- No backwards-compat migration tooling.
- No support for non-git distribution (tarballs, mirrors). Both SSH (`git@host:...`) and HTTPS (`https://...`) git URLs are valid install URLs; the agent picks the transport.
- No version-conflict resolution across SEEDs.
- No `/populate`, `/wrapup`, `/install-seed`, or pre-commit hook in v0.
