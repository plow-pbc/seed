# Purpose

> See [[README#Purpose]] for the canonical purpose. This `SEED.md` is the complete RFC 2119 contract: an AI agent or engineer reading this file (and the sub-folder SEEDs it links to) MUST be able to (re)build the SEED convention, the `/populate` and `/wrapup` skills, and the optional pre-commit hook from scratch.

**Status:** v0 (initial) &middot; **Date:** 2026-05-08

## Normative Language

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL in this document are to be interpreted as described in RFC 2119.

`Implementation-defined` means the behavior is part of the implementation contract, but this specification does not prescribe a single policy. Implementations MUST document their selected behavior.

## 1. Problem

End-of-session context dies in chat scrollback. Knowledge accumulated across sessions has nowhere durable to live. Existing PKM tools either over-shoot (heavy stack with embeddings and install ceremony) or under-shoot (raw markdown with no convention an AI can target).

SEED solves this with:

- A lightweight, recursively-readable convention (§ 2).
- Two Claude Code skills that read and write the convention (`/populate`, `/wrapup`).
- An optional shell-side pre-commit hook that warns on drift.

Goal: any folder MUST be readable as a self-contained mental model, and the tree as a whole MUST be reconstructable from its SEED files alone.

## 2. The Convention

### 2.1 Folder shape

Every SEED-participating folder MUST contain a `SEED.md`. The folder MAY also contain a `README.md`.

A `SEED.md`'s purpose MUST be defined in the closest sibling-or-ancestor `README.md` (sibling preferred; if no sibling `README.md` exists, the closest ancestor `README.md` defines the purpose).

The repo root MUST have both `README.md` (marketing front door) and `SEED.md` (top-level contract).

Sub-folders MAY have only `SEED.md` (no sibling `README.md`); their purpose is then defined by the closest ancestor `README.md`.

### 2.2 README.md shape

A SEED-participating `README.md` MUST contain:

- `# SEED` as the H1.
- A `## Purpose` H2 section that defines the purpose in marketing-readable prose. The H2 anchor `Purpose` is the canonical back-reference target.

A SEED-participating `README.md` MAY contain additional H2 sections (`## Install`, `## License`, demo video block, etc.). Those are human-facing prose; they have no machine semantics.

### 2.3 SEED.md shape

A `SEED.md` MUST open with a `# Purpose` H1 that wikilinks to the closest sibling-or-ancestor `README.md`'s `## Purpose` section. Format:

> See `[[<relative-path-to-README>#Purpose]]` for the canonical purpose. *{one-sentence description of how this SEED implements that purpose}*.

After the `# Purpose` H1, the body of `SEED.md` MUST be one of two flavors (§ 2.3.1, § 2.3.2). It MUST NOT mix flavors at the same level; a folder that needs both install and spec content SHOULD split into sub-folders.

A `SEED.md` MUST contain exactly one H1 — the opening `# Purpose`. All structural headings below MUST be H2 (`##`) or deeper. This avoids markdown-linter conflicts and keeps the `# Purpose` back-reference anchor unambiguous.

#### 2.3.1 Install-flavor

Used for environment-setup folders, index folders that mostly enumerate dependencies, and worked examples. The body MUST contain (in this order):

- `## Dependencies` — bullet list of external (system, package) and internal (sub-folder SEED) dependencies, with block IDs.
- `## Install` — step-by-step commands.
- `## Verify` — runnable smoke checks.

The body MAY contain `## Open` (loose ends, deferred items) and additional folder-specific H2 sections that document binding contracts the folder owns. Additional sections MUST appear after the three required sections.

#### 2.3.2 Spec-flavor

Used for folders that contain code (or code-to-be-written). The body MUST contain (in this order):

- `## Components` — the named entities (functions, classes, files), with block IDs.
- `## API` — public contract (signatures, inputs, outputs, errors). RFC 2119 throughout.
- `## Install` or `## Build` — how to wire the component into a working install.
- `## Verify` — conformance tests (runnable commands + expected outcomes).

The body MAY contain `## Non-Goals`, `## Open`, and additional folder-specific H2 sections that document binding contracts the folder owns. Additional sections MUST appear after the four required sections.

A spec-flavor `SEED.md` MUST be sufficient (in conjunction with the SEEDs it depends on) to write the software from scratch.

### 2.4 Block IDs

Block IDs use Obsidian's native `^id` syntax. They are deterministic and stable across small edits.

- Section anchors use canonical short forms: `^purpose`, `^deps`, `^verify`, `^open`, `^components`, `^api`.
- Bullet anchors use `<section-prefix>-<slugified-bold-name>`. Example: `^dep-claude-code`, `^obj-populate`, `^api-trigger`.
- Numeric suffix on collision: `^htr`, `^htr2`.

### 2.5 Wikilinks

Cross-references between SEEDs MUST use Obsidian-style wikilinks:

- Whole-section: `[[<relative-path>/SEED#<section-name>]]` (heading-text anchor).
- Block-level: `[[<relative-path>/SEED#^<block-id>]]`.
- README purpose back-reference: `[[<relative-path>/README#Purpose]]`.

A `SEED.md` MUST NOT use bare paths or HTML anchors for cross-references.

Heading anchors MUST use the **literal full heading text**, including any leading section numbers. Example: `[[SEED#2.6 Hierarchical Invariant]]`, NOT `[[SEED#2.6]]`. When a stable cross-reference to a numbered section is needed, a block-level anchor (`#^id`) is RECOMMENDED — it survives heading-text edits.

### 2.6 Hierarchical Invariant

When a parent SEED depends on a child folder's SEED, the parent's `## Dependencies` (install-flavor) or `## Components` (spec-flavor) MUST link to the child via `[[<child>/SEED#Purpose]]`.

Forward-references to unborn folders (folders that do not yet exist on disk) MUST NOT appear in `## Dependencies` or `## Components`. Forward-looking content MUST live in a `README.md`'s `## Roadmap` section instead.

A folder that has a `SEED.md` but no implementing code is **not** an unborn folder — its SEED is the spec for the unwritten code, and the unwritten artifacts live in that SEED's `## Open`.

## 3. Components

The seed repo's components are described in sub-folder SEEDs:

- [[skills/SEED#Purpose]] — install-flavor index for the two skills shipped here. ^comp-skills
- [[skills/populate/SEED#Purpose]] — spec-flavor contract for `/populate`. ^comp-populate
- [[skills/wrapup/SEED#Purpose]] — spec-flavor contract for `/wrapup`. ^comp-wrapup
- [[hooks/SEED#Purpose]] — install+spec hybrid for the optional pre-commit drift warning. ^comp-hooks
- [[examples/SEED#Purpose]] — install-flavor; a worked example showing the convention applied recursively. ^comp-examples

A reader who walks `cat **/SEED.md` (or follows the wikilinks down) MUST end with a complete understanding of every shipped component.

## 4. Install Protocol

### Step 0 — Verify prerequisites

```bash
git --version                                   # any modern git
echo "$BASH_VERSION"                             # POSIX shell
ls ~/.claude/skills/ >/dev/null 2>&1 && echo "skills dir OK"
```

If any check fails, install `git` / `bash` / Claude Code first.

### Step 1 — Clone the seed repo

```bash
test -d ~/Hacking/seed || git clone https://github.com/plow-pbc/seed.git ~/Hacking/seed
```

### Step 2 — Symlink skills

```bash
mkdir -p ~/.claude/skills/
for s in populate wrapup; do
  test -d ~/Hacking/seed/skills/$s || { echo "skill $s not yet shipped, skipping"; continue; }
  test -e ~/.claude/skills/$s && { echo "refusing to overwrite ~/.claude/skills/$s"; exit 1; }
  ln -sfn ~/Hacking/seed/skills/$s ~/.claude/skills/$s
done
```

The installer MUST symlink (not copy) so edits in `~/Hacking/seed/` propagate. The installer MUST refuse to overwrite an existing entry at `~/.claude/skills/<skill>`.

### Step 3 — Reload Claude Code

Start a new Claude Code session. Skills load on session start.

### Step 4 — Run conformance test

```bash
cd ~/Hacking/seed
test "$(head -1 README.md)" = "# SEED"           # README H1 is # SEED
grep -q '^## Purpose' README.md                   # README has ## Purpose
grep -q '^# Purpose' SEED.md                      # SEED.md opens with # Purpose
grep -q '^## Normative Language' SEED.md          # RFC 2119 declared
```

All four checks MUST pass.

## 5. Verify (full conformance)

The full conformance test for an installation:

1. `README.md` H1 is `# SEED` and contains `## Purpose`. ^v-readme
2. Every `SEED.md` in the tree opens with `# Purpose` and a wikilink back-reference to a `README.md`'s `## Purpose`. ^v-purpose-ref
3. Every wikilink resolves (target file + section exists). ^v-links
4. `## Dependencies` / `## Components` link only to existing folders (no forward-references to unborn folders, per § 2.6). ^v-no-forward-refs
5. `/populate` and `/wrapup` are loadable in Claude Code (visible via the Skill tool) once their `SKILL.md` files ship. ^v-skills

A non-conforming repo MUST be diagnosed with the failing check named.

## 6. Non-Goals (v0)

- No embeddings, vector search, or DB.
- No automated session detection. `/wrapup` runs only when typed.
- No multi-user collaboration; personal-use shape only.
- No backwards-compat migration tooling. v0 is greenfield.
- No `/wrapup --reconcile` AI-merge for SEED conflicts across parallel checkouts.
- No Claude Code Stop hook for AI-side end-of-session reminders. Pre-commit drift warning covers the main case.

## 7. Open

- Demo video has not been recorded; the README's poster and mp4 paths are placeholders. ^o-demo
- `/populate` skill is unimplemented — see [[skills/populate/SEED#Open]]. ^o-populate
- `/wrapup` skill is unimplemented — see [[skills/wrapup/SEED#Open]]. ^o-wrapup
- Pre-commit hook is unimplemented — see [[hooks/SEED#Open]]. ^o-hooks
- Worked example is unimplemented — see [[examples/SEED#Open]]. ^o-examples
^open
