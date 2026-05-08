# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the spec-flavor contract for `/install-seed`: a Claude Code skill that reads any SEED and installs the software it describes by walking the dependency graph and executing the install + verify protocols.

## Components

- `SKILL.md` — the Claude Code skill file (frontmatter + body). ^obj-skillmd
- `install-seed.md` — OPTIONAL extended runbook the skill loads when invoked. ^obj-runbook

## API

### Trigger

- `/install-seed <target>` — install the SEED rooted at `<target>`. The argument MUST be one of:
  - A local path to a folder containing `SEED.md` (e.g. `~/Hacking/seed/examples/autoresearch`).
  - An HTTPS git URL (e.g. `https://github.com/plow-pbc/seed.git`); the repo MUST be cloned to `~/Hacking/<repo-name>/` if not already present.
  - An HTTPS URL to a raw `SEED.md`; the surrounding folder is fetched if accessible, otherwise the skill operates on the single file (no recursion possible).

### Inputs

- The target's `README.md` and `SEED.md`.
- Recursively, any sub-folder SEEDs referenced in the target's `## Dependencies` via `[[<child>/SEED#Purpose]]` wikilinks.
- The user, who MUST confirm each shell block before execution.

### Algorithm (MUST)

1. **Resolve target.** If a git URL: clone to `~/Hacking/<repo-name>/` (skip if already present, but verify it tracks the same remote). If a raw-SEED URL: fetch and write to a temporary path. If a local path: MUST be a readable folder containing `SEED.md`.
2. **Read `SEED.md`.** The skill MUST refuse if the file does not contain `# Purpose` H1 and `## Normative Language` declaring RFC 2119 (i.e. is not a SEED conforming to [[../../SEED#2.3 SEED.md shape]]).
3. **Determine flavor** (per [[../../SEED#2.3 SEED.md shape]]). The skill MUST refuse spec-flavor SEEDs with the error: *"spec-flavor SEEDs describe code to be written, not installable software; hand the SEED to your agent for implementation, or `/install-seed` a SEED that depends on the spec-flavor one."*
4. **Walk `## Dependencies`.** For each dep that is a wikilink to a sub-SEED (`[[<child>/SEED#Purpose]]`), recurse into `/install-seed` against `<target>/<child>/`. For each external dep (system package, language runtime), surface to the user with a one-line summary; the skill MUST NOT auto-install external system packages without an explicit `## Install` block in the dependency's SEED.
5. **Run `## Install`.** For each fenced shell block in the section, the skill MUST display the block to the user and wait for explicit confirmation before execution. Confirmed blocks MUST run with `bash -e` semantics; the first non-zero exit aborts the install.
6. **Run `## Verify`.** Each fenced shell block in the section MUST be executed; the skill MUST NOT mark install successful until every verify block passes. Failing verify MUST surface clearly with exit code and stderr.
7. **Report.** A summary log: which SEEDs ran (in walk order), which deps were deferred to the user, which install/verify blocks passed/failed.

### Outputs

- A cloned repo (if a URL was passed) at `~/Hacking/<repo-name>/`.
- Side effects from the install commands (the skill itself writes nothing outside that).
- A summary log printed to the user.

### Errors

- The skill MUST refuse paths that escape the user's home directory (`~/`) or `/tmp/`.
- The skill MUST redact secrets in stdout/stderr to `…<last 3 chars>`.
- The skill MUST NOT call external services beyond the initial git clone or raw-SEED fetch.
- The skill MUST NOT auto-commit anywhere.
- The skill MUST NOT silently retry failed install or verify blocks; surface the failure and stop.

## Install

Once `SKILL.md` is written, the skill is installed by symlink (see [[../SEED#Install]]).

## Verify

Self-install (the seed repo can install itself):

```
/install-seed https://github.com/plow-pbc/seed.git
```

Expected: clones to `~/Hacking/seed/` (if not already present), walks dependencies (transitive sub-SEEDs), all verify blocks pass.

Then the worked example:

```
/install-seed ~/Hacking/seed/examples/autoresearch
```

Expected: recursively resolves the CUDA dep first, then installs autoresearch (clones it, installs `uv`, runs `uv sync`, runs `prepare.py`), then runs autoresearch's verify.

## Non-Goals

- `/install-seed` MUST NOT handle spec-flavor SEEDs (those describe code-to-be-written, not installable software).
- `/install-seed` MUST NOT auto-install external system packages (drivers, language runtimes) unless the dependency SEED explicitly provides `## Install` blocks for them.
- `/install-seed` MUST NOT modify global system state outside what the SEED's `## Install` section explicitly does.
- `/install-seed` MUST NOT auto-resolve version conflicts between SEEDs (deferred to v1).

## Open

- `SKILL.md` not yet written. ^o-skillmd
- Recursion-bottom heuristic (when does `/install-seed` stop walking deps?) not yet pinned. RECOMMENDED: stop at the first SEED whose `## Dependencies` has zero sub-SEED wikilinks. ^o-recursion
- Behavior for partial install failures (rollback? leave partial?) not yet pinned. ^o-rollback
- Confirmation UX (per-block vs per-section vs all-at-once) not yet pinned. ^o-confirm
^open
