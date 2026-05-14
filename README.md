# SEED

A recursive spec format. Hand your agent a SEED URL; the agent installs the software.

<!-- TODO: record demo. Poster + mp4 should live in .github/media/ -->

[![SEED demo poster](.github/media/seed-demo-poster.jpg)](.github/media/seed-demo.mp4)

_Demo: an agent reads a SEED, walks its dependency graph leaves-first, and installs the system. The spec is ground truth; the install is one realization._

## Purpose

In a world where software is free, the value will be the spec. SEED is a common, recursive definition for that spec. With this base SEED, you can build and run any other published SEED in your personal environment, and in a way that's personalized to your needs.

This repo is the base SEED. The convention lives in [`SEED.md`](SEED.md) — RFC 2119 normative, hierarchical, recursive (every folder gets a `SEED.md`).

Every SEED has the same shape: `## Dependencies → ## Objects → ## Actions → ## Verify`, plus optional `## Feedback`, `## Open`, `## Non-Goals`. The canonical grammar with RFC 2119 qualifiers lives in [`SEED.md`](SEED.md) at `^seed-grammar`. Plain markdown. No DB. No embeddings. No runtime.

The trick: the format describes itself in the same language it describes everything else. An agent that can read this repo's SEED can read any SEED.

## Install

Tell any AI agent:

> Install `git@github.com:plow-pbc/seed.git`

That's it. The agent clones the URL, reads `SEED.md`, and answers the `## Verify` prompts (confirming any shell each prompt asks it to run) — which checks the convention is structurally sound. This repo ships no installable software; it ships the convention. CI / non-AI callers can run the deterministic equivalent at [`ref/verify.sh`](https://github.com/plow-pbc/seed/blob/main/ref/verify.sh).

## Hello world

The worked example lives in its own repo: **[plow-pbc/seed-autoresearch](https://github.com/plow-pbc/seed-autoresearch)**. It installs @karpathy's [autoresearch](https://github.com/karpathy/autoresearch) on a Linux + NVIDIA machine via two composed SEEDs (cuda → autoresearch):

> Install `git@github.com:plow-pbc/seed-autoresearch.git`

Reading both repos side-by-side is the fastest way to understand the convention: this repo *defines* it, that repo *uses* it.

## License

MIT.
