# Purpose

> See [[README#Purpose]].

## Dependencies

- Claude Code v1.0+ with skill loading enabled.
- `git` on the host (for clone-mode installs).

## Objects

### SKILL.md ^obj-skillmd-install

- The agent entry point at `ref/skills/seed-install/SKILL.md`. YAML frontmatter (`name`, `description`) at the top; natural-language install procedure below.

### Trust gate ^obj-trustgate-install

- The non-negotiable per-block confirmation declared at the top of SKILL.md. Every shell block under `## Dependencies` and every shell prompted by `## Verify` MUST be displayed in full and confirmed before execution.

### Input modes ^obj-modes-install

- `Clone mode` (git URL → clone → `cd`), `Local mode` (existing path with `SEED.md`), `CWD mode` (`.` or empty arg). Clone mode rejects URLs with userinfo, query, or fragment before display or execution (per [[../../../SEED#^act-install-clone-url]]); all three pass user input as `argv`, never interpolated.

## Actions

### SEED is installed

This skill is the reference implementation of [[../../../SEED#^act-install]]; that contract is the source of truth and this folder is one realization. ^act-install-delegated

## Verify

1. **SKILL.md present.** Does `SKILL.md` exist at the root of this folder with a YAML frontmatter block declaring `name` and `description`? Expected: yes.
2. **Trust gate declared.** Does SKILL.md declare the per-block confirmation gate as non-negotiable for all repo-supplied shell? Expected: yes.
3. **Delegation honored.** Does SKILL.md follow the parent contract at [[../../../SEED#^act-install]] without contradicting it? Expected: yes.
