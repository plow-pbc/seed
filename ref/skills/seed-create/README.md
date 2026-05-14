# seed-create

## Purpose

The reference Claude Code skill for authoring a new SEED-conforming repo. Interview-driven, draft-in-memory until approved, never pushes.

The natural-language contract this skill implements lives at [[../../../SEED#^act-author]]. This skill is one realization of that contract; alternative implementations (a different host, a different language) MAY live in separate repos.

## Install

Symlink or install via plugin so Claude Code discovers it as a skill:

```bash
ln -s "$REPO_ROOT/ref/skills/seed-create" ~/.claude/skills/seed-create
```

Then `/seed-create` from inside Claude Code.

## License

MIT (inherits from the parent repo).
