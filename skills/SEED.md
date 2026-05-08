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

## Open

- Neither `populate/` nor `wrapup/` contains a `SKILL.md` yet (only sub-folder SEEDs). ^o-skill-files
^open
