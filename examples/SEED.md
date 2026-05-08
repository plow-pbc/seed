# Purpose

> See [[../README#Purpose]] for the canonical purpose. This `SEED.md` is the install-flavor index for the worked "hello world" example: a real-world install of @karpathy's [autoresearch](https://github.com/karpathy/autoresearch) (an autonomous LLM training experimentation loop) demonstrated through three composed SEEDs.

The hello-world is intentionally non-trivial: it shows recursive composition. The autoresearch SEED depends on a sibling CUDA SEED (GPU runtime) and on the parent seed repo (which provides `/install-seed`). Reading the example top-down MUST be enough to install autoresearch from a fresh machine.

## Dependencies

- [[autoresearch/SEED#Purpose]] — the autoresearch application SEED. ^dep-autoresearch
- [[cuda/SEED#Purpose]] — the CUDA / NVIDIA runtime SEED (transitive, via autoresearch). ^dep-cuda
- [[../SEED#Purpose]] — this seed repo (transitive; provides `/install-seed`). ^dep-seed

## Install

```
/install-seed ~/Hacking/seed/examples/autoresearch
```

`/install-seed` walks the dependency graph: cuda first (driver + toolkit), then autoresearch (clone + uv + uv sync + prepare.py). Each shell block in each child SEED requires user confirmation per [[../skills/install-seed/SEED#API]].

## Verify

```bash
nvidia-smi                                         # GPU detected, driver loaded
ls ~/Hacking/autoresearch/                          # repo present
ls ~/.cache/autoresearch/ | grep -E 'shard|tokenizer'    # data prepped
```

All three checks MUST succeed once the example is fully installed.

## Open

- The CUDA SEED targets Linux + a single discrete NVIDIA GPU only. macOS / AMD / Windows variants are deferred to forks; autoresearch's README lists notable forks for those platforms. ^o-platform
- The autoresearch baseline training run (`uv run train.py`, ~5 min) is RECOMMENDED but slow; the example marks it as optional in [[autoresearch/SEED#Open]]. ^o-baseline-runtime
^open
