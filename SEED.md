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
- MAY contain `## Open` and/or `## Non-Goals` after the required sections.

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

All five checks MUST exit zero.

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
