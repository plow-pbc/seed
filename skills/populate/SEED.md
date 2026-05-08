# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the spec-flavor contract for `/populate`: a Claude Code skill that synthesizes `SEED.md` files from filesystem signals.

## Components

- `SKILL.md` — the Claude Code skill file (frontmatter + body). ^obj-skillmd
- `populate.md` — OPTIONAL extended runbook the skill loads when invoked. ^obj-runbook

## API

### Trigger

- `/populate` — operate on cwd at depth 1.
- `/populate -L N` — BFS recurse to depth N. The implementation MUST reject N < 1; N > 5 is implementation-defined (RECOMMENDED clamp to 5).

### Inputs

- The current working directory.
- Filesystem layout. The skill MUST skip hidden directories, `node_modules/`, `.git/`, `target/`, `dist/`, `build/`, `__pycache__/`, and anything matched by the nearest enclosing `.gitignore`.
- Metadata files: `README.md`, `package.json`, `pyproject.toml`, `Cargo.toml`, `justfile`, `Makefile`, `go.mod`.
- Existing `SEED.md` files. The skill MUST preserve user content; deltas MUST be proposed as diffs and confirmed before write.

### Algorithm (MUST)

1. **Resolve vault root.** Walk up from cwd while each parent has a `SEED.md`. The topmost such ancestor is vault root. If no ancestor has a `SEED.md`, the skill MUST propose creating one at cwd.
2. **BFS folders** up to depth N (default 1).
3. **For each folder, read existing `SEED.md` if any.** Parse subsections by `^## ` headings.
4. **Synthesize each subsection** from filesystem signals:
   - **Dependencies** — package metadata deps + `[[<child>/SEED#Purpose]]` refs for sub-folders that have a `SEED.md`.
   - **Components** (spec-flavor) — top-level named entities (entry points, exports, configs) with `(path)` hints.
   - **Install** / **Build** — scripts in `package.json`, `justfile`, `Makefile`, `pyproject.toml`.
   - **Verify** — detected test runner (`just test`, `npm test`, `pytest`, `cargo test`, `go test`).
5. **If `SEED.md` does not exist at the target folder, the skill MUST propose creating one** with the appropriate flavor (install vs spec — see § Heuristics).
6. **If no sibling `README.md` exists and no ancestor `README.md` is found,** the skill MUST propose creating a `README.md` with `# SEED` H1 + `## Purpose` H2 at the vault root.
7. **Show diff per file.** The user confirms / edits / rejects per section.
8. **Apply hierarchical invariant** ([[../../SEED#2.6 Hierarchical Invariant]]).
9. **Write files. The skill MUST NOT auto-commit.**

### Heuristics (implementation-defined)

The flavor (install vs spec) for a generated `SEED.md` is implementation-defined. RECOMMENDED:

- **Spec-flavor** when the folder contains source files (`.py`, `.ts`, `.tsx`, `.go`, `.rs`, `.ex`, `.exs`, `.java`, `.kt`, `.rb`, `.swift`, `.c`, `.h`, `.cpp`, `.hpp`).
- **Install-flavor** when the folder is index-only (only sub-folders + metadata) or environment-setup (`.tool-versions`, `Dockerfile`, `setup.sh`, `Brewfile`).

When ambiguous, the skill MUST ask the user.

### Outputs

- Zero or more new or modified `SEED.md` files.
- Zero or more new `README.md` files (only when no sibling/ancestor `README.md` is found at vault root).
- A summary log printed to the user.

### Errors

- The skill MUST refuse to write outside the resolved vault root.
- The skill MUST refuse to overwrite hand-written prose without explicit user confirmation per section.
- The skill MUST redact secrets in any inferred content to `…<last 3 chars>`.
- The skill MUST NOT call any external service (no embeddings, no third-party LLM beyond the host agent).

## Install

Once `SKILL.md` is written, the skill is installed by symlink (see [[../SEED#Install]]).

## Verify

In Claude Code, against a fresh tree:

```bash
mkdir -p /tmp/populate-test/foo/bar
cd /tmp/populate-test
# Then in Claude Code: /populate -L 2
```

Expected:

- `/tmp/populate-test/README.md` exists with `# SEED` H1 + `## Purpose` H2.
- `/tmp/populate-test/SEED.md` exists with `# Purpose` + appropriate sections.
- `/tmp/populate-test/foo/SEED.md` exists with `# Purpose` back-ref to `[[../README#Purpose]]`.
- `/tmp/populate-test/foo/bar/SEED.md` exists with `# Purpose` back-ref to `[[../../README#Purpose]]`.
- All wikilinks resolve.
- No `git commit` was performed.

## Non-Goals

- `/populate` MUST NOT execute code or run tests.
- `/populate` MUST NOT auto-commit.
- `/populate` MUST NOT call external services.

## Open

- `SKILL.md` not yet written. ^o-skillmd
- Heuristic for install-vs-spec flavor not yet pinned. ^o-flavor-heuristic
- Block-ID generation specifics (max-length, collision policy) not yet pinned. ^o-blockid
- Test-runner priority when multiple are detected (`just test` + `pytest` both present) not yet pinned. ^o-test-priority
^open
