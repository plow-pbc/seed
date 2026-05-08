# SEED

> Recursively-readable mental-model files for code repos. Every folder gets a structured contract; the filesystem becomes a graph of meaning that any AI agent or new collaborator can read top-down.

<!-- TODO: record demo. Poster + mp4 should live in .github/media/ -->

[![SEED demo poster](.github/media/seed-demo-poster.jpg)](.github/media/seed-demo.mp4)

_In the demo, an agent runs `/populate` on a fresh repo, walks the tree, and writes a `SEED.md` in each participating folder. A second agent then reads the tree top-down (`cat **/SEED.md` + follow links) and reconstructs the project from those files alone. Recursive readability is the conformance criterion._

## Purpose

Every code folder needs a few facts an agent or new collaborator must land on: what's here, how to verify it works, what depends on it, what's open. SEED captures those with a fixed shape so the answers always live in the same place — and the same shape composes recursively up the tree.

This repo ships:

- The **SEED convention** itself ([`SEED.md`](SEED.md)) — RFC 2119 contract, sufficient to (re)build the toolkit.
- The **`/populate` skill** — synthesizes `SEED.md` files from filesystem signals.
- The **`/wrapup` skill** — at session-end, updates `SEED.md` files with what was learned.
- An **optional pre-commit hook** that warns when staged code drifts from its sibling SEED.

Plain markdown. No runtime, no DB, no embeddings.

## Install

### Option 1 — Build it from the spec

Tell your favorite coding agent:

> Implement SEED according to the spec in
> https://github.com/plow-pbc/seed/blob/main/SEED.md

### Option 2 — Use the reference skills

In any directory, paste into Claude Code:

> Install `plow-pbc/seed`. If `~/Hacking/seed/` does not exist, clone
> `https://github.com/plow-pbc/seed.git` there. Then open
> `~/Hacking/seed/SEED.md` § 4 (Install Protocol) and follow it.

Start a new Claude Code session to load skills. `/populate` and `/wrapup` then become available everywhere.

## License

MIT.
