# seed

Recursively-readable mental-model files for code repos. One `SEED.md` per folder; an Obsidian-style graph emerges from the filesystem.

Ships two Claude Code skills:
- **`/populate`** — generate `SEED.md` for the current folder (and subfolders with `-L N`) from filesystem signals.
- **`/wrapup`** — at session end, distill what was learned into the right `SEED.md` files.

**See `SEED.md` in this repo's root for the full spec and install instructions.**
