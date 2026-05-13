---
name: seed-install
description: Use when the user wants to install a SEED from a git URL, local path, or current directory. Walks ## Dependencies leaves-first with per-block shell confirmation, then runs ## Verify. Fires the feedback report if the root SEED opts in.
---

# Installing a SEED

Reference implementation of the natural-language contract at [[../../SEED#^act-install]]. The procedure lives in `SEED.md`; this skill is the call site.

## Trust gate (non-negotiable)

Every shell block under `## Dependencies` and every shell prompted by `## Verify` MUST be displayed in full and confirmed by the user before execution. No batching, no "approve all", no `--yes` flag. This is the only invariant the agent can enforce from outside the SEED's source.

## Inputs

Parse the single arg into one of three modes:

1. **Clone mode** — arg matches `https://...` or `git@host:...` (per SEED.md's supported transports). Ask the user once where to clone; default to `$HOME/Hacking/<repo>/`, falling back to `<default>2`, `<default>3`, etc. if the default already exists. Clone with `git clone <url> <target>`.

2. **Local mode** — arg is a path that exists and contains a `SEED.md`. `cd` into it; skip cloning.

3. **CWD mode** — empty arg or `.`. Treat the current working directory as the SEED root. Confirm `SEED.md` exists there; abort otherwise.

## Procedure

Once the SEED root is established, follow [[../../SEED#^act-install]] literally — including the recursive walk of `## Dependencies` wikilinks and external SEED URLs (leaves-first), executing every shell block with user confirmation, then answering every `## Verify` prompt.

The procedure is defined ONCE in SEED.md. Do not restate it here.

## Feedback dispatch

After reaching a terminal state (`success`, `failure`, or `aborted`), evaluate [[../../SEED#^act-feedback]] against the root SEED's `## Feedback` section. Fire at most one report. The consent banner, the payload schema, and the disable mechanisms are all specified there.

## Failure surface

On any user-aborted shell block:

1. Stop the walk immediately.
2. Mark the install `aborted`.
3. Fire the feedback report if eligible.
4. Report partial state to the user: what installed, what didn't, where to resume from. Do not auto-retry.

## Non-goals for v1

- No resume from partial install (rerun from the top).
- No parallel sub-SEED installation (leaves-first stays sequential).
- No dry-run flag (per-block confirmation is the review surface).
- No alternate transport beyond git URLs.
