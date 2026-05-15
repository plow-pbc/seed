# Purpose

> See [[README#Purpose]].

## Dependencies

- Claude Code v1.0+ with skill loading enabled. Surfaced to the user; the SEED MAY describe install but MUST NOT assume the agent can run it without confirmation.

## Objects

### SKILL.md ^obj-skillmd-create

- The agent entry point at `ref/skills/seed-create/SKILL.md`. YAML frontmatter (`name`, `description`) at the top; natural-language authoring procedure below.

### Hard gate ^obj-hardgate-create

- The pre-disk-write approval gate declared at the top of SKILL.md (per [[../../../SEED#^act-author]]).

### Three-tier confirmation ^obj-tiers-create

- The tier model SKILL.md uses to advance through the interview (per [[../../../SEED#^obj-tier]]).

## Actions

### SEED is authored

This skill is the reference implementation of [[../../../SEED#^act-author]]; that contract is the source of truth and this folder is one realization. ^act-author-delegated

## Verify

1. **SKILL.md present.** Does `SKILL.md` exist at the root of this folder with a YAML frontmatter block declaring `name` and `description`? Expected: yes.
2. **Hard gate declared.** Does SKILL.md declare the no-disk-writes-until-approval gate before any disk-writing step? Expected: yes.
3. **Delegation honored.** Does SKILL.md follow the parent contract at [[../../../SEED#^act-author]] without contradicting it? Expected: yes.

## Open

- Round-trip hand-test not yet automated (see parent SEED's `^o-wrapup`).
