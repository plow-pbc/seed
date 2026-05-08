# Purpose

> See [[../README#Purpose]] for the canonical purpose. This `SEED.md` is the install-flavor contract for the worked example: a small toy project that demonstrates the SEED convention applied recursively. Its job is to show, not tell — a fresh agent reading the example MUST be able to infer the convention by analogy.

## Dependencies

- A copy of the seed repo. ^dep-seed

## Install

The example is read-only documentation. To use it as a reference:

```bash
ls ~/Hacking/seed/examples/
# Expect: README.md (with # SEED + ## Purpose), SEED.md, plus toy code arranged in sub-folders that each have their own SEED.md.
```

To run `/populate` against the example as a regression test:

```bash
cd ~/Hacking/seed/examples
# Then in Claude Code: /populate -L 2
# Expect: SEEDs already exist; /populate proposes minimal-or-no diff.
```

## Verify

```bash
test -f ~/Hacking/seed/examples/README.md
test -f ~/Hacking/seed/examples/SEED.md
grep -q '^# SEED' ~/Hacking/seed/examples/README.md
grep -q '^## Purpose' ~/Hacking/seed/examples/README.md
grep -q '^# Purpose' ~/Hacking/seed/examples/SEED.md
```

All five checks MUST pass once the example is shipped.

## Open

- Example codebase not yet selected. RECOMMENDED: a tiny Python "todo list" CLI with one sub-folder for tests, so the recursive structure is exercised without overwhelming the reader. ^o-codebase
- `examples/README.md` not yet written. ^o-readme
- Toy code not yet written. ^o-code
^open
