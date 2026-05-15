---
name: seed-install
description: Use when the user wants to install a SEED from a git URL, local path, or current directory. Walks ## Dependencies leaves-first with per-block shell confirmation, then runs ## Verify. Fires the feedback report if the root SEED opts in.
---

# Installing a SEED

Reference implementation of the natural-language contract at [[../../../SEED#^act-install]]. The procedure lives in `SEED.md`; this skill is the call site.

## Trust gate (non-negotiable)

Every shell block under `## Dependencies` and every shell prompted by `## Verify` MUST be displayed in full and confirmed by the user before execution. No batching, no "approve all", no `--yes` flag. This is the only invariant the agent can enforce from outside the SEED's source.

The skill's own pre-SEED commands (clone, cd) ALSO display + confirm — the user-supplied URL/path is untrusted shell data until the SEED is read and the trust model applies. Pass user input as `argv` (never interpolated into a shell-quoted string), and use `--` to terminate flag parsing where the tool supports it.

## Inputs

The three input modes (clone / local / CWD) are defined in [[../../../SEED#^act-install-modes]]. This skill's per-mode operational rules:

1. **Clone mode** — Enforce the URL hygiene rule at [[../../../SEED#^act-install-clone-url]]: reject URLs with userinfo, query, or fragment before passing to `git clone`. Ask the user once where to clone; if the chosen path already exists, suggest `<path>2`, `<path>3`, etc. Display and confirm the clone command before running: `git clone -- <url> <target>` (the `--` prevents a URL starting with `-` from being parsed as a flag). After the URL-hygiene gate, the displayed URL matches the canonical `seed_url` form the feedback payload uses (see [[../../../SEED#^act-feedback]]) with no further redaction needed.

2. **Local mode** — Display and confirm the `cd -- <path>` before running. Abort if `<path>/SEED.md` doesn't exist.

3. **CWD mode** — Confirm `SEED.md` exists in the cwd; abort otherwise.

## Procedure

Once the SEED root is established, follow [[../../../SEED#^act-install]] literally.

The procedure is defined ONCE in SEED.md. Do not restate it here.

## Failure surface

On terminal (`failure` or `aborted`), report partial state to the user: what installed, what didn't, where it stopped. Do not auto-retry. State-machine transitions, terminal reasons, and feedback dispatch all live in `[[../../../SEED#^obj-install-states]]` + `[[../../../SEED#^act-feedback]]`.

## Non-Goals for v1

- No resume from partial install (rerun from the top).
- No parallel sub-SEED installation (leaves-first stays sequential).
- No dry-run flag (per-block confirmation is the review surface).
- No alternate transport beyond git URLs.
