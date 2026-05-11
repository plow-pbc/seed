# Purpose

> See [[../README#Purpose]] for the canonical purpose. This `SEED.md` is the install index for the worked "hello world" example: a real install of @karpathy's [autoresearch](https://github.com/karpathy/autoresearch) demonstrated through two composed sub-SEEDs.

## Dependencies

- [[autoresearch/SEED#Purpose]] — the autoresearch application SEED. ^dep-autoresearch
- [[cuda/SEED#Purpose]] — the CUDA / NVIDIA runtime SEED (transitive via autoresearch). ^dep-cuda

This index runs no shell. Installation happens by recursing into the wikilinks above.

## Objects

- `autoresearch/SEED.md` — the autoresearch application SEED. ^obj-autoresearch-seed
- `cuda/SEED.md` — the CUDA / NVIDIA runtime SEED. ^obj-cuda-seed

## Actions

- An agent reading this SEED follows `[[autoresearch/SEED#Purpose]]` to install autoresearch. ^act-follow-autoresearch
- The autoresearch SEED then recursively follows `[[../cuda/SEED#Purpose]]` to install CUDA first.
- This index itself runs no shell.

## Verify

```bash
test -f $REPO_ROOT/autoresearch/SEED.md
test -f $REPO_ROOT/cuda/SEED.md
```

Both files MUST exist.

## Non-Goals

- This index intentionally does NOT install anything itself. All install shell lives in the child SEEDs.
