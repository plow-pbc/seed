# seed

> Recursively-readable mental-model files for code repos. One folder,
> one structured contract. Filesystem becomes a graph.

This repo ships two Claude Code skills (`/populate`, `/wrapup`) that
read and write to the SEED convention. Pure markdown. No runtime, no
DB, no embeddings.

## Why

Most folders need a few key facts an agent or new collaborator must
land on: what's here, how to verify it works, what depends on it,
what's open. The `## SEED` section captures those with a fixed shape
so the answers are always in the same place.

## Tenets

- **No runtime, no DB, no embeddings.** Plain markdown.
- **Manual `/wrapup` only.** Human chooses when to crystallize.
- **No coupling with personal dotfiles.** Standalone, forkable.

## Dependencies

- POSIX shell, `git`.
- Claude Code with `~/.claude/skills/` writable.
- *(Optional)* Obsidian.

## Install

In any directory, paste into Claude Code:

> "Install `plow-pbc/seed`. Read `~/Hacking/seed/README.md`'s
> `## SEED > ### Verify` section and follow it."

Start a new Claude Code session to load skills.

## SEED

The present-tense contract for *this* folder. Read this section
recursively across the tree to reconstruct the project.

### Objects
- **README.md** — project overview + SEED contract + roadmap. ^obj-readme
- **LICENSE** — MIT. ^obj-license

### Actions
- **Read top-down** — `cat */README.md` and follow `### Sub-trees`
  links downward. ^act-read

### Verify
- `head -1 README.md` is `# seed`.
- README contains `## SEED` with `### Objects`, `### Actions`,
  `### Verify`, `### Sub-trees` subsections.
- All wikilinks in `### Sub-trees` point at folders that exist.
^verify

### Sub-trees
*(none yet — Phase 2+ will add `skills/`, `hooks/`, `examples/`.)*

## Roadmap

- [x] Phase 0: bootstrap (LICENSE, README, .gitignore).
- [x] Phase 1: README with `## SEED` section.
- [ ] Phase 2: `/populate` skill.
- [ ] Phase 3: `/wrapup` skill.
- [ ] Phase 4: examples + install verify.
- [ ] Phase 5: pre-commit drift hook.

## License

MIT.
