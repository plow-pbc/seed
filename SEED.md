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
- MUST contain `# SEED` as H1.
- MUST contain a `## Purpose` H2 section (marketing-readable prose).
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
- Contains: sub-SEED wikilinks, external system requirements, external repo clones, repo setup commands.
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
- MUST NOT mutate state produced by `## Dependencies`.
- MAY create ephemeral test resources (containers, sandboxes, digital twins); MUST clean them up before exit.
- Shell blocks do NOT require user confirmation (read-only by spec).
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
  3. For each `[[<child>/SEED#Purpose]]` wikilink in `## Dependencies`, recursively installing the child SEED first.
  4. Executing every shell block under `## Dependencies` (user-confirmed per block).
  5. Executing `## Verify`.
- Order: leaves-first, root-last.

### SEED is verified

- An agent runs the shell blocks under `## Verify`. ^act-verify
- All blocks MUST exit zero for the SEED to be considered installed.
- Verify is read-only and idempotent; the agent MAY run it any time, including BEFORE trusting a fresh install.

### SEED is trusted

- The agent MUST treat `## Dependencies` as high-trust (executes arbitrary shell). ^act-trust
- The agent MUST treat `## Objects`, `## Actions`, `## Verify` as low-trust (no side effects on installed state).
- This trust boundary is why Verify is read-only by spec: it remains a safe re-runnable check even when the installed state is suspect.

## Verify

The conformance test for this `SEED.md`:

```bash
test "$(head -1 README.md)" = "# SEED"
grep -q '^## Purpose' README.md
grep -q '^# Purpose' SEED.md
grep -q '^## Normative Language' SEED.md
grep -qE '^## Dependencies$' SEED.md
grep -qE '^## Objects$' SEED.md
grep -qE '^## Actions$' SEED.md
grep -qE '^## Verify' SEED.md
```

All eight checks MUST pass.

The full tree conformance (every `SEED.md` in this repo):

```bash
for f in $(find . -name 'SEED.md' -not -path './.git/*'); do
  head -3 "$f" | grep -q 'README#Purpose' || { echo "FAIL no back-ref: $f"; exit 1; }
  grep -q '^# Purpose' "$f" || { echo "FAIL no Purpose H1: $f"; exit 1; }
  for sec in Dependencies Objects Actions Verify; do
    grep -q "^## $sec" "$f" || { echo "FAIL no ## $sec: $f"; exit 1; }
  done
done
echo "tree conforms"
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
- No support for non-git distribution (tarballs, mirrors). HTTPS git URLs only.
- No version-conflict resolution across SEEDs.
- No `/populate`, `/wrapup`, `/install-seed`, or pre-commit hook in v0.
