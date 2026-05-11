# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the install contract for the NVIDIA driver + CUDA toolkit that autoresearch (and other GPU SEEDs) depend on: a discrete NVIDIA GPU, a recent driver, and `nvidia-smi` reachable on `$PATH`.

## Dependencies

- External: A discrete NVIDIA GPU. Linux x86_64. RECOMMENDED H100, A100, or RTX 30-series or newer. ^dep-gpu
- External: A Linux distribution with a recent kernel. Ubuntu 22.04+ tested. ^dep-os
- External: `sudo` access (driver install requires root). ^dep-sudo

This SEED is implementation-defined for non-Linux / non-NVIDIA platforms. On macOS, AMD, or Windows: refer to autoresearch's [notable forks](https://github.com/karpathy/autoresearch#notable-forks) and substitute that fork's CUDA-equivalent install. On Linux + NVIDIA, follow the steps below.

### Detect GPU

```bash
lspci | grep -i nvidia
```

If empty, this machine has no NVIDIA GPU; abort and use a CPU-only fork.

### Install NVIDIA driver

On Ubuntu 22.04+:

```bash
sudo apt update
sudo apt install -y nvidia-driver-535
```

A reboot MAY be required before `nvidia-smi` works.

### Install CUDA toolkit (OPTIONAL)

The autoresearch dependency stack pulls CUDA via PyTorch wheels at `uv sync` time, so a system-wide CUDA toolkit is OPTIONAL for autoresearch specifically. Install it only if other SEEDs need `nvcc` or system CUDA libraries:

```bash
sudo apt install -y nvidia-cuda-toolkit
```

## Objects

- `/dev/nvidia*` — device nodes created by the driver. ^obj-devnodes
- `/usr/bin/nvidia-smi` — driver-shipped CLI for inspecting GPU state. ^obj-smi
- `/usr/lib/x86_64-linux-gnu/libnvidia*` — driver shared libraries. ^obj-libs

## Actions

- The driver exposes the GPU via `/dev/nvidia*` device nodes; userspace libraries `dlopen` the corresponding shared libraries to perform CUDA operations. ^act-expose
- `nvidia-smi` reports driver version, CUDA-runtime version, GPU model, memory state, and per-process utilization. ^act-smi-report

## Verify

```bash
nvidia-smi | grep -qE 'Driver Version: [0-9]+'
lspci | grep -qi nvidia
test -c /dev/nvidia0
```

All three checks MUST succeed.

## Open

- Driver/toolkit version compatibility with PyTorch is implementation-defined; autoresearch's `uv sync` resolves the PyTorch wheel that matches the installed driver. Exotic driver versions MAY require pinning a specific PyTorch wheel manually. ^o-version-compat

## Non-Goals

- ROCm (AMD) and MPS (Apple Silicon) variants are out-of-scope; this SEED targets NVIDIA + Linux only.
- Multi-GPU and distributed configurations are not covered; autoresearch is single-GPU by design.
