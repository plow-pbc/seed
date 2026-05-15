# seed-install

## Purpose

The reference Claude Code skill for installing a SEED from a git URL, local path, or current working directory. Walks `## Dependencies` leaves-first with per-block user confirmation, then runs `## Verify`. Fires the feedback report if the root SEED opts in.

The natural-language contract this skill implements lives at [[../../../SEED#^act-install]]. This skill is one realization of that contract.

## Install

Symlink or install via plugin so Claude Code discovers it as a skill:

```bash
ln -s "$REPO_ROOT/ref/skills/seed-install" ~/.claude/skills/seed-install
```

Then `/seed-install <git-url-or-path>` from inside Claude Code.

## License

MIT (inherits from the parent repo).
