# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the install-flavor contract for installing @karpathy's [autoresearch](https://github.com/karpathy/autoresearch): a small single-GPU LLM training loop designed for autonomous overnight experimentation by a coding agent.

## Dependencies

- [[../cuda/SEED#Purpose]] — NVIDIA driver + CUDA toolkit (autoresearch requires a single discrete NVIDIA GPU). ^dep-cuda
- [[../../SEED#Purpose]] — this seed repo (provides `/install-seed`, the entry point that walks this SEED). ^dep-seed
- External: Python 3.10+. ^dep-python
- External: `uv` project manager (installed inline in `## Install` Step 2). ^dep-uv
- External: `git`, ~5 GB free disk for the dataset cache. ^dep-disk

## Install

### Step 0 — Verify prerequisites

```bash
nvidia-smi                                # MUST list at least one GPU
python3 --version                         # MUST be ≥ 3.10
git --version
df -h ~ | tail -1                         # MUST show ≥ 5 GB available on $HOME
```

If `nvidia-smi` fails, the CUDA SEED ([[../cuda/SEED#Install]]) MUST be installed first.

### Step 1 — Clone the autoresearch repo

```bash
test -d ~/Hacking/autoresearch || git clone https://github.com/karpathy/autoresearch.git ~/Hacking/autoresearch
```

### Step 2 — Install `uv`

```bash
command -v uv || curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv --version
```

### Step 3 — Install Python dependencies

```bash
cd ~/Hacking/autoresearch && uv sync
```

`uv sync` resolves the PyTorch wheel that matches the installed CUDA driver. If this step fails with a CUDA mismatch, re-run [[../cuda/SEED#Install]] Step 3 to verify the driver, then retry.

### Step 4 — Download data and train tokenizer (one-time, ~2 min)

```bash
cd ~/Hacking/autoresearch && uv run prepare.py
```

This downloads the training shards and trains a BPE tokenizer into `~/.cache/autoresearch/`.

### Step 5 — Sanity-check with a baseline training run (OPTIONAL, ~5 min)

```bash
cd ~/Hacking/autoresearch && uv run train.py
```

The baseline run finishes in ~5 minutes wall-clock and prints a `val_bpb:` line to stdout. `/install-seed` MAY skip this step (see [[#Open]]) and defer it to first manual run for faster install loops.

## Verify

```bash
ls ~/Hacking/autoresearch/                                          # repo cloned
ls ~/.cache/autoresearch/ | grep -E 'tokenizer|shard'               # data + tokenizer present
test -f ~/Hacking/autoresearch/.venv/bin/python                     # uv env created
nvidia-smi                                                          # GPU still visible
```

All four checks MUST succeed.

## Open

- Step 5 (baseline training run) is RECOMMENDED but slow. The implementer of `/install-seed` MAY support a `--no-baseline` flag that skips Step 5; the user can then run it manually for the first sanity check. ^o-baseline-opt
- Smaller-compute tuning (lower DEPTH, lower MAX_SEQ_LEN, TinyStories dataset) is documented in autoresearch's upstream README under "Platform support" but NOT covered by this SEED — it would be a separate `examples/autoresearch-small/` SEED. ^o-small-compute
^open
