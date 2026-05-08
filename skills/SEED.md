# Purpose

> See [[../README#Purpose]] for the canonical purpose. This `SEED.md` is the install-flavor index for the two Claude Code skills shipped in this repo: `/populate` and `/wrapup`.

## Dependencies

- Claude Code (with `~/.claude/skills/` writable). ^dep-claude
- POSIX shell, `git`. ^dep-shell
- [[populate/SEED#Purpose]] — `/populate` skill spec. ^dep-populate
- [[wrapup/SEED#Purpose]] — `/wrapup` skill spec. ^dep-wrapup

## Install

The skills are installed via symlinks from `~/.claude/skills/`:

```bash
ln -sfn ~/Hacking/seed/skills/populate ~/.claude/skills/populate
ln -sfn ~/Hacking/seed/skills/wrapup   ~/.claude/skills/wrapup
```

Reload Claude Code; `/populate` and `/wrapup` become available.

The installer MUST symlink (not copy). The installer MUST refuse to overwrite an existing real file at `~/.claude/skills/<skill>` (a stale symlink MAY be replaced).

## Verify

```bash
test -L ~/.claude/skills/populate && readlink ~/.claude/skills/populate
test -L ~/.claude/skills/wrapup   && readlink ~/.claude/skills/wrapup
```

Both checks MUST pass and each symlink MUST resolve to `~/Hacking/seed/skills/<name>`.

## Claude Code Skill Format

Each skill in this repo is a **Claude Code skill**: a single markdown file (with YAML frontmatter) that the host agent loads at session start and consults when the user invokes the matching slash command. The format below is the dependency contract every skill in this repo MUST follow. ^skill-format

### File layout

A skill MUST live at `<skill-name>/SKILL.md` (e.g. `populate/SKILL.md`, `wrapup/SKILL.md`). The directory name and the skill's frontmatter `name` MUST match. After install ([[#Install]]), `~/.claude/skills/<skill-name>` is a symlink to `~/Hacking/seed/skills/<skill-name>/`. The skill file itself MUST be named `SKILL.md` (case-sensitive) so the host agent finds it. ^skill-layout

### Frontmatter

`SKILL.md` MUST begin with YAML frontmatter delimited by `---` lines:

```yaml
---
name: <skill-name>
description: <one-line trigger description; the host agent consults this to decide when to invoke the skill>
---
```

The `name` and `description` fields are REQUIRED. Implementations MAY add host-defined fields (e.g. `model:` to pin a specific model for the skill). Unknown fields MUST be ignored by conforming implementations. ^skill-frontmatter

### Body

The body of `SKILL.md` (everything after the closing `---`) is markdown read in full by the host agent when the user invokes `/<skill-name>`. The body MUST encode the skill's API contract from its spec-flavor SEED ([[populate/SEED#API]], [[wrapup/SEED#API]]) — algorithm steps, MUST/MUST NOT obligations, error cases, refusal conditions. The body is not executable code; it is operating instructions the host agent reads and follows. ^skill-body

### Invocation

The host agent invokes the skill when the user types `/<skill-name>` at the prompt (e.g. `/populate`). Arguments after the slash command (e.g. `/populate -L 2`) are passed verbatim to the agent; the agent MUST parse them per the skill's API spec. The skill MUST NOT define its own argument parser outside the markdown body. ^skill-invocation

### Diff and confirmation

Skills that propose file changes MUST surface diffs via the host agent's `Edit` and `Write` tools (which natively show diffs to the user before writing) and MUST NOT write outside that flow. Skills MUST NOT auto-commit; see [[populate/SEED#Errors]] and [[wrapup/SEED#Errors]] for the per-skill obligations. ^skill-diff

### Discovery

The host agent scans `~/.claude/skills/` on session start and registers each child directory whose `SKILL.md` parses as a valid skill (name + description present). Newly-installed skills become available after the next session reload. ^skill-discovery

## Open

- Neither `populate/` nor `wrapup/` contains a `SKILL.md` yet (only sub-folder SEEDs). ^o-skill-files
^open
