# Purpose

> See [[README#Purpose]] for the canonical purpose. This `SEED.md` is the complete RFC 2119 contract for the SEED convention. Reading it MUST be sufficient to (re)build the convention itself and validate that other SEEDs conform.

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
- The `# Purpose` H1 MUST wikilink to the closest sibling-or-ancestor `README.md`'s `## Purpose` section.
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
- Verify is **normatively read-only on installed state** — an authoring contract: the SEED author MUST NOT put state-mutating commands here.
- MAY create ephemeral test resources (containers, sandboxes, digital twins); MUST clean them up before exit.
- Shell blocks MUST be displayed to the user and explicitly confirmed before execution. The agent cannot prove that an author actually honored the read-only contract from the source — confirmation is the only gate that holds for both authoring mistakes and malicious SEEDs.
- Block IDs use `^v-<slug>`.

### Feedback section

- An OPTIONAL H2 section that declares the destination for install reports. ^obj-feedback
- Three legal body forms:
  - `(default — agent uses plow's hub.)` — agent uses plow's default endpoint (`https://plow.io/seed/feedback` until otherwise specified). ^obj-feedback-default
  - An **HTTPS URL** on its own line (e.g. `https://feedback.acme.internal/seed-reports`) — agent uses that URL (for company-internal SEEDs reporting to private endpoints). Non-HTTPS destinations MUST be rejected by the agent (no plaintext transport for machine-linked reports). ^obj-feedback-custom
  - `(none)` — feedback explicitly disabled for this SEED. ^obj-feedback-none
- **Absent `## Feedback` means feedback is OFF for this SEED.** No reports are sent. Authors who want feedback MUST add an explicit `## Feedback` section with one of the three legal body forms. (Privacy-by-default: a SEED predating this convention does not silently become a reporting SEED when an agent rolls forward.)
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
  5. Executing `## Verify` (user-confirmed per block).
- Order: leaves-first, root-last.

### SEED is verified

- An agent runs the shell blocks under `## Verify` with the same per-block confirmation gate used for `## Dependencies`. ^act-verify
- All blocks MUST exit zero for the SEED to be considered installed.
- Verify is normatively read-only and idempotent (an authoring contract). The agent has no way to prove read-only-ness from the source, so confirmation is required even on re-verification.

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

#### Destination resolution

Reading the root SEED's `## Feedback` body (whitespace-trimmed):

1. Body is `(none)` → no report.
2. Body is `(default — agent uses plow's hub.)` → agent uses plow's default endpoint (`https://plow.io/seed/feedback` until otherwise specified).
3. Body is a single line parseable as an HTTPS URL → agent uses that URL.
4. Any other body (HTTP URL, malformed text, multi-line body, etc.) → no report. The agent SHOULD log a one-line warning to stderr.

#### Consent — opt-out with **per-destination** banner

- Before the first report to each distinct destination URL on a machine, the agent MUST display a one-time banner naming **that** destination, the fields collected, and the disable instructions.
- After the banner is acknowledged for a destination, the agent records the acknowledgement keyed by destination URL in `~/.config/seed/feedback.json`. A different destination on the same machine MUST re-prompt — consent to one URL is not consent to another. Example state file:

  ```json
  {
    "enabled": true,
    "destinations": {
      "https://plow.io/seed/feedback":            "2026-05-11T20:30:00Z",
      "https://feedback.acme.internal/seed-reports": "2026-05-11T21:00:00Z"
    }
  }
  ```

- Disable mechanisms (any one suppresses sending):
  - Env var `SEED_FEEDBACK=off` for the current shell session.
  - `~/.config/seed/feedback.json` containing `{"enabled": false}` — disables globally for this machine.
  - Per-SEED override via `## Feedback\n\n(none)` — author-side opt-out.

#### Payload

- A markdown document with YAML frontmatter, GitHub-issue-shaped, with at minimum: `seed_url`, `seed_commit`, `outcome`, `failing_section`, `failing_block_index`, `exit_code`, `os`, `arch`, `anon_machine_id`, `ts`. Optional `## Note` body for user-provided free-form text.
- The agent MUST NOT collect: paths, env vars, hostnames, shell output, stack traces, or any PII.
- `anon_machine_id` is the first 16 hex chars of `sha256(hostname + per_machine_salt)`. The salt is generated on first run and stored locally in `~/.config/seed/machine-id`. Wiping the salt rotates the ID.

#### Failure modes

- Feedback failures (network, 4xx/5xx, timeout, malformed body, non-HTTPS URL) MUST be silently dropped.
- Reporting failures MUST NOT propagate to the install outcome. A user whose install succeeded but whose report failed to transmit MUST see a successful install.
- No retry queue or offline buffering in v0. Lost reports are lost.

## Verify

The conformance checks below are runnable from the repo root. Each command MUST exit zero.

The README must contain a `## Purpose` H2 (the back-reference target). The H1 is not constrained.

```bash
grep -q '^## Purpose' README.md
```

`SEED.md` must have exactly one H1, and that H1 must be `# Purpose`. (Counts of `^# ` lines and the literal H1 value.)

```bash
test "$(grep -c '^# [^#]' SEED.md)" -eq 1
test "$(grep '^# [^#]' SEED.md)" = "# Purpose"
```

The root SEED declares RFC 2119:

```bash
grep -q '^## Normative Language' SEED.md
```

Required H2 sections appear in the spec-mandated order:

```bash
diff <(grep -E '^## (Dependencies|Objects|Actions|Verify)$' SEED.md) \
     <(printf '## Dependencies\n## Objects\n## Actions\n## Verify\n')
```

The `## Feedback` section is present (this SEED opts into the protocol):

```bash
grep -q '^## Feedback' SEED.md
```

All six checks MUST exit zero.

The full tree conformance (every `SEED.md` in this repo, including sub-folder SEEDs that inherit RFC 2119 from the root):

```bash
fail=0
for f in $(find . -name 'SEED.md' -not -path './.git/*'); do
  test "$(grep -c '^# [^#]' "$f")" -eq 1       || { echo "FAIL multiple H1: $f"; fail=1; continue; }
  test "$(grep '^# [^#]' "$f")" = "# Purpose"  || { echo "FAIL H1 not '# Purpose': $f"; fail=1; continue; }
  head -3 "$f" | grep -q 'README#Purpose'      || { echo "FAIL no README#Purpose back-ref: $f"; fail=1; continue; }
  diff <(grep -E '^## (Dependencies|Objects|Actions|Verify)$' "$f") \
       <(printf '## Dependencies\n## Objects\n## Actions\n## Verify\n') >/dev/null \
       || { echo "FAIL required H2s not in order: $f"; fail=1; continue; }
done
test "$fail" = "0" && echo "tree conforms"
```

All `SEED.md` files in the tree MUST pass.

## Feedback

(default — agent uses plow's hub.)

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
