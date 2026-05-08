# Purpose

> See [[../README#Purpose]] for the canonical purpose. This `SEED.md` specs an OPTIONAL pre-commit hook that warns when staged code in folder X has changed but `X/SEED.md` (and `X/README.md`) have not — surfacing drift between code and contract.

## Dependencies

- POSIX shell. ^dep-shell
- `git` (any modern version). ^dep-git

## Components

- `pre-commit` — shell script invoked by `git`. ^obj-pre-commit
- `install-in-repo.sh` — opt-in installer that sets `core.hooksPath`. ^obj-installer
- `test/test-pre-commit.sh` — POSIX-shell test for the hook's behavior. ^obj-test

## API

### `pre-commit`

The hook reads `git diff --cached --name-only`, groups the staged paths by enclosing folder, and for each folder F where any non-SEED, non-README file is staged: if `F/SEED.md` and `F/README.md` are both unchanged in this commit, the hook MUST emit a warning to stderr naming the folder and the staged paths.

The hook MUST exit 0 in all cases (warning only; never blocks the commit).

The hook MUST NOT run any AI / LLM call.

### `install-in-repo.sh`

The installer sets the target repo's `core.hooksPath` to point at `~/Hacking/seed/hooks/`.

The installer MUST abort with a non-zero exit if `core.hooksPath` is already set in the target repo (no silent override).

The installer is per-repo opt-in; it MUST NOT modify any global git config.

## Install

```bash
cd <target-repo>
~/Hacking/seed/hooks/install-in-repo.sh
```

To uninstall:

```bash
cd <target-repo>
git config --unset core.hooksPath
```

## Verify

```bash
~/Hacking/seed/hooks/test/test-pre-commit.sh
```

The test MUST exercise:

1. **Drift case** — non-SEED file staged, `SEED.md` unchanged → warning emitted, exit 0. ^v-drift
2. **Clean case** — non-SEED file staged AND `SEED.md` updated → no warning, exit 0. ^v-clean
3. **No-drift case** — only `SEED.md` itself staged → no warning, exit 0. ^v-only-seed
4. **Abort-on-existing-hooksPath** — installer aborts cleanly if `core.hooksPath` is already configured. ^v-abort

All four cases MUST pass.

## Non-Goals

- The hook MUST NOT run AI-side analysis. (Drift warning only.)
- The hook MUST NOT block commits.
- The hook MUST NOT inspect file contents (path-level reasoning only).

## Open

- `pre-commit` script not yet implemented. ^o-pre-commit
- `install-in-repo.sh` not yet implemented. ^o-installer
- `test/test-pre-commit.sh` not yet implemented. ^o-test
^open
