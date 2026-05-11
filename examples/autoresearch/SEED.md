# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the install contract for @karpathy's [autoresearch](https://github.com/karpathy/autoresearch): a single-GPU LLM training loop designed for autonomous overnight experimentation by a coding agent.

## Dependencies

- [[../cuda/SEED#Purpose]] — NVIDIA driver + CUDA toolkit (autoresearch requires a discrete NVIDIA GPU). ^dep-cuda
- External: Python 3.10+, git, ~5 GB free disk in `$HOME`. ^dep-system

`$AUTORESEARCH_ROOT` is the agent's chosen location for the autoresearch checkout. It is distinct from `$REPO_ROOT` (which is the folder containing this `SEED.md` inside the seed repo).

### Prereq check

```bash
nvidia-smi
python3 --version
git --version
df -h $HOME | tail -1
```

`python3 --version` MUST report ≥ 3.10. If `nvidia-smi` fails, install [[../cuda/SEED#Purpose]] first.

### Clone the autoresearch repo

```bash
test -d $AUTORESEARCH_ROOT || git clone https://github.com/karpathy/autoresearch.git $AUTORESEARCH_ROOT
```

### Install `uv`

```bash
command -v uv || curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv --version
```

### Install Python dependencies

```bash
cd $AUTORESEARCH_ROOT && uv sync
```

### Download data and train tokenizer (one-time, ~2 min)

```bash
cd $AUTORESEARCH_ROOT && uv run prepare.py
```

## Objects

- `$AUTORESEARCH_ROOT/prepare.py` — fixed data prep + tokenizer (MUST NOT be modified). ^obj-prepare
- `$AUTORESEARCH_ROOT/train.py` — model + optimizer + training loop; the file agents edit. ^obj-train
- `$AUTORESEARCH_ROOT/program.md` — agent instructions; the experiment-loop runbook. ^obj-program
- `$AUTORESEARCH_ROOT/pyproject.toml` — Python dependency manifest. ^obj-pyproject
- `$AUTORESEARCH_ROOT/.venv/` — uv-managed virtualenv. ^obj-venv
- `$HOME/.cache/autoresearch/` — local data cache (shards + tokenizer). ^obj-cache

## Actions

- `prepare.py` downloads training shards and trains a BPE tokenizer into `$HOME/.cache/autoresearch/`. Idempotent; runs once per machine. ^act-prepare
- `train.py` loads data from `$HOME/.cache/autoresearch/`, runs training on the configured GPU for ~5 minutes wall clock, prints a `val_bpb:` metric. Modifiable by the agent. ^act-train
- `program.md` instructs the agent on the experiment loop: edit `train.py`, commit, run, check `val_bpb`, advance the branch if improved. ^act-program

The autoresearch repo is designed for an agent to read `program.md` and iterate on `train.py` autonomously. Once installed, the agent runs experiments indefinitely until interrupted.

## Verify

```bash
test -d $AUTORESEARCH_ROOT
test -f $AUTORESEARCH_ROOT/.venv/bin/python
ls $HOME/.cache/autoresearch/ | grep -E 'tokenizer|shard'
nvidia-smi
```

All four checks MUST succeed.

## Open

- Smaller-compute tuning (lower `DEPTH`, lower `MAX_SEQ_LEN`, TinyStories dataset) is documented in autoresearch's upstream README but NOT covered by this SEED — that would be a separate `examples/autoresearch-small/` SEED. ^o-small-compute

## Non-Goals

- Multi-GPU and distributed training are out-of-scope (autoresearch is single-GPU by design).
- macOS, AMD, and Windows variants are non-goals; see autoresearch's [notable forks](https://github.com/karpathy/autoresearch#notable-forks) for those platforms.
