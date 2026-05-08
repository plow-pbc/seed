# SEED

A recursive, machine-readable spec format. Hand your agent a SEED; the agent builds the software.

<!-- TODO: record demo. Poster + mp4 should live in .github/media/ -->

[![SEED demo poster](.github/media/seed-demo-poster.jpg)](.github/media/seed-demo.mp4)

_Demo: an agent reads a SEED, walks its dependency graph, and writes the implementation. A second agent reads the same SEED in a different language and produces a different implementation that passes the same conformance test. The spec is ground truth; the code is one realization of it._

## Purpose

In a world where software is free, the value will be the spec. SEED is a common, recursive definition for that spec. With this base SEED, you can build and run any other published SEED in your personal environment, and in a way that's personalized to your needs.

This repo is the base SEED. The convention itself lives in [`SEED.md`](SEED.md) — RFC 2119 normative, hierarchical, recursive (every folder gets one). Two flavors: install-flavor (deps + install + verify) for environment setup, spec-flavor (components + API + verify) for code-to-be-written. The dependency graph is the directory tree. Read top-down; build bottom-up.

On top of the convention, this repo ships three Claude Code skills:

- `/populate` — synthesize `SEED.md` files from filesystem signals.
- `/wrapup` — update `SEED.md` files at session end with what was learned.
- `/install-seed` — read any SEED and install the software it describes (walks the dependency graph, runs install + verify with per-block confirmation).

Plus an optional pre-commit hook that warns when staged code drifts from its sibling SEED, and a worked example: installing @karpathy's [autoresearch](https://github.com/karpathy/autoresearch) via three composed SEEDs (cuda → autoresearch → seed).

Plain markdown. No DB. No embeddings. No runtime.

The trick: the format describes itself in the same language it describes everything else. An agent that can read this repo can read any SEED, including SEEDs it generates for you.

## Install

Two ways. Pick one.

### Build it from the spec

Hand the spec to your coding agent:

> Implement SEED from the spec at
> https://github.com/plow-pbc/seed/blob/main/SEED.md

That's the install. The spec contains everything the agent needs.

### Use the reference skills

Bootstrap (once):

```bash
git clone https://github.com/plow-pbc/seed.git ~/Hacking/seed
```

Then in Claude Code:

> Open `~/Hacking/seed/SEED.md` § 4 and follow it.

Reload Claude Code. `/populate`, `/wrapup`, and `/install-seed` are available everywhere.

Try the worked example:

```
/install-seed ~/Hacking/seed/examples/autoresearch
```

It installs @karpathy's autoresearch by walking three composed SEEDs (cuda for the GPU runtime, then autoresearch itself), confirming each shell block before running.

## License

MIT.
