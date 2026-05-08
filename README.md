# seed

> Recursively-readable mental-model files for code repos. One `SEED.md` per folder. An Obsidian-style graph emerges from the filesystem.

```
~/Hacking/
  SEED.md           ← top-of-tree mental map
  plow/
    SEED.md         ← project-wide concepts
    api/
      SEED.md       ← API-specific concepts
```

Each `SEED.md` follows a fixed schema (`Purpose`, `Dependencies`, `Objects`, `Actions`, `Verify`, optional `Tenets`/`Open`, `Sub-trees`). Reading the tree top-down should be sufficient to understand and rebuild the project.

## Two skills

- **`/populate`** — generate `SEED.md` for the current folder (and subfolders with `-L N`) from filesystem signals (README, package metadata, file layout).
- **`/wrapup`** — at session end, distill what was decided/learned into the right `SEED.md` files.

Both are pure Claude Code SKILL.md files. No runtime, no DB.

## Install

Open Claude Code in any directory and paste:

> "Install `plow-pbc/seed` on this machine. Read `~/Hacking/seed/SEED.md` and follow its `## Verify` section."

Claude does the rest. Then start a new Claude Code session to load the skills.

## Full spec

See [`SEED.md`](SEED.md) — the install steps live in its `## Verify` section. The format itself is documented in [`schema/SEED.md`](schema/SEED.md).

## License

MIT.
