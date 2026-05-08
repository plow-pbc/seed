# seed — recursively-readable mental-model files

This repo defines the `SEED.md` convention and ships two Claude Code skills (`/populate`, `/wrapup`) that read and write SEED.md files. Cloning this repo and following the `## Verify` section below installs the skills system-wide.

## Purpose
Give every folder in your hacking workspace a single durable file that captures *what this folder is, what it owns, what depends on it, and how to verify it's working*. The filesystem hierarchy becomes a recursively-readable mental model. An AI agent or a fresh human reader can `cat */SEED.md` top-down and reconstruct the project.
^purp

## Dependencies
- A POSIX shell, `git`. ^dep-posix
- Claude Code with `~/.claude/skills/` already a writable directory. ^dep-claude
- (Optional) Obsidian, with the vault root opened at the highest folder containing a `SEED.md`. ^dep-obsidian

## Objects
- **Schema** ([[schema/SEED]]) — the `SEED.md` format spec. The single source of truth for what a conformant seed looks like. ^obj-schema
- **Skills** ([[skills/SEED]]) — index of the skills shipped here. *(Arrives in Phase 2 (`/populate`) and Phase 3 (`/wrapup`).)* ^obj-skills
- **Hooks** ([[hooks/SEED]]) — optional opt-in pre-commit drift warning. *(Arrives in Phase 5.)* ^obj-hooks
- **Examples** ([[examples/SEED]]) — worked example. *(Arrives in Phase 4.)* ^obj-examples

## Actions
- **Install** — clone this repo and symlink the skill directories into `~/.claude/skills/` per `## Verify` below. ^act-install
- **Use** — once installed, type `/populate` (or `/populate -L 3`) in any folder, or `/wrapup` at session end. ^act-use

## Verify

**Install (run these as a Claude Code session — paste the prompt below):**

> "Install `plow-pbc/seed` on this machine. If `~/Hacking/seed/` does not exist, clone `https://github.com/plow-pbc/seed.git` there. Then run the four shell commands in the install block of `~/Hacking/seed/SEED.md`'s `## Verify` section. Tell me when done and remind me to start a new Claude Code session to load the skills."

**Install commands** (Claude executes these, in order):

```bash
# 1. Clone if absent (idempotent).
[ -d ~/Hacking/seed ] || git clone https://github.com/plow-pbc/seed.git ~/Hacking/seed

# 2. Make sure ~/.claude/skills/ exists.
mkdir -p ~/.claude/skills

# 3. Refuse to overwrite existing non-symlink targets.
for s in wrapup populate; do
  t=~/.claude/skills/$s
  if [ -e "$t" ] && [ ! -L "$t" ]; then
    echo "Refusing to overwrite real file at $t — move it aside and re-run." >&2
    exit 1
  fi
done

# 4. Symlink (idempotent).
ln -sfn ~/Hacking/seed/skills/wrapup    ~/.claude/skills/wrapup
ln -sfn ~/Hacking/seed/skills/populate  ~/.claude/skills/populate
```

**Verify install succeeded:**

```bash
test -L ~/.claude/skills/wrapup    && echo "wrapup OK"
test -L ~/.claude/skills/populate  && echo "populate OK"
```

Both should print `OK`. After this, **start a new Claude Code session** — skills load at session start.

**Verify the skills work** (in a new session, in a sandbox dir):

```bash
mkdir -p /tmp/seed-test/api && cd /tmp/seed-test
echo "# Demo project" > README.md
echo "// API entry" > api/server.ts
```

Then in Claude: `/populate -L 2`. Expect: a proposed diff creating `/tmp/seed-test/SEED.md` (root) and `/tmp/seed-test/api/SEED.md`. Confirm the diff and `cat` the files to verify the schema.

^verify

## Tenets
- **No runtime, no DB, no embeddings.** SEED files are plain markdown; the skills are pure Claude prompts. Differentiator vs. heavier PKM stacks. ^ten-light
- **Manual `/wrapup` only.** No automatic session detection. The human chooses when knowledge is ready to crystallize. ^ten-manual
- **No coupling with personal dotfiles.** This repo is a standalone artifact. Anyone can fork without inheriting unrelated config. ^ten-stand

## Sub-trees
- [[schema/SEED]] — the `SEED.md` format spec.
- [[skills/SEED]] — `/populate` and `/wrapup` SKILL.md files. *(Arrives in Phase 2 + Phase 3.)*
- [[hooks/SEED]] — opt-in pre-commit drift warning. *(Arrives in Phase 5.)*
- [[examples/SEED]] — worked example: this repo seeded by itself. *(Arrives in Phase 4.)*
