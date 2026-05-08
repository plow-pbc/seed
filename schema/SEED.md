# schema — the SEED.md format

Defines the file convention used by every other `SEED.md` in this repo and by every repo that installs seed. This file *is* itself a `SEED.md` and demonstrates the convention recursively.

## Purpose
Provide a single, recursively-readable convention for per-folder mental-model files. Reading a tree of `SEED.md` files top-down should be sufficient to understand and rebuild the project they describe.
^purp

## Objects
- **`SEED.md`** — one per folder. Visible (no dot prefix). Markdown with a fixed section schema. ^obj-seed
- **Section** — a top-level `## Heading` plus its body and optional block ID. ^obj-sec
- **Block ID** — Obsidian-native `^id` line; makes a section or bullet deep-linkable as `[[file#^id]]`. ^obj-bid

## Actions
- **Read recursively** — `cat */SEED.md` from a parent and follow `## Sub-trees` links downward. The output should be a buildable picture of the project. ^act-read
- **Deep-link** — wikilink with anchor: `[[plow/api/SEED#^htr]]` jumps to the `^htr` block. Whole-section: `[[plow/api/SEED#Verify]]`. ^act-link

## Verify

A `SEED.md` is conformant if and only if (a) sections appear in the canonical order, (b) only listed section names are used, (c) every nested `SEED.md` is linked from its parent's `## Sub-trees`.

Run `/populate` (after seed is installed; see [[../SEED]]'s `## Verify`) to regenerate from filesystem signals and diff against the existing version.

**Canonical template** — section order is fixed: `Purpose → Dependencies → Objects → Actions → Verify → Tenets → Open → Sub-trees`. Skip what doesn't apply; never reorder. Only listed section names are used.

```markdown
# <folder-name> — <one-line purpose>

[Optional 1-paragraph context.]

## Purpose
1–3 sentences.
^purp

## Dependencies
- [[../shared/SEED]] — what it provides. ^dep-shared
- External: PostgreSQL 16, OPENAI_API_KEY in env.

## Objects
- **API server** (`server.ts`) — Express app. ^obj-srv
- **Quote generator** (`quote.ts`) — cache-then-upstream. ^obj-quote

## Actions
- **Serve HTTP** — `bun dev`; API server starts on :3000. ^act-serve
- **Generate quote** — POST /v1/quote → cached or fresh. ^act-quote

## Verify
- `just test --filter api` — N unit tests pass.
- `bun dev` → GET /healthz → expect `200 {"ok":true}`.
^verify

## Tenets
- **Fail-fast over defensive guards.** ^ten-ff

## Open
- Caching layer for /v1/verify is undecided. ^open-cache

## Sub-trees
- [[handlers/SEED]] — request handlers.
- [[middleware/SEED]] — auth, logging.
```

^verify

## Tenets
- **Locality.** A folder's seed lives next to its code, not in a centralized vault. ^ten-loc
- **Boring markdown.** Plain text, no proprietary syntax beyond Obsidian wikilinks/block IDs. ^ten-md
- **Bold for normative emphasis** — Karpathy `program.md` register. No RFC 2119 MUST/SHOULD ceremony. ^ten-bold
- **Block IDs are auto-generated, deterministic.** Section anchors: lowercase first 3–4 chars of the section name (`^purp`, `^verify`, `^open`; `^ten` when the section is `## Tenets`). Bullet anchors: section-prefix + dash + slugified bold-name (lowercase, hyphens, max 8 chars) — `Objects → ^obj-…`, `Actions → ^act-…`, `Dependencies → ^dep-…`, `Tenets → ^ten-…`, `Open → ^open-…`. Collisions: numeric suffix (`^htr`, `^htr2`). `Sub-trees` bullets do not get block IDs (they're nav, not concepts). ^ten-bid
- **Wikilinks are vault-root-relative.** Vault root = the highest ancestor that has a `SEED.md`. Examples (vault root = `~/Hacking/`): `[[plow/api/SEED]]` (link to a child seed), `[[plow/api/SEED#^htr]]` (deep-link to the `^htr` block), `[[plow/api/SEED#Verify]]` (deep-link to the `Verify` section by heading). ^ten-wl
