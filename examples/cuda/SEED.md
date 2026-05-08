# Purpose

> See [[../../README#Purpose]] for the canonical purpose. This `SEED.md` is the install-flavor contract for the CUDA / NVIDIA runtime that autoresearch (and other GPU SEEDs) depend on: a discrete NVIDIA GPU, a recent driver, and `nvidia-smi` reachable on `$PATH`.

## Dependencies

- External: A discrete NVIDIA GPU, Linux x86_64. RECOMMENDED H100, A100, or RTX 30-series or newer. ^dep-gpu
- External: A Linux distribution with a recent kernel. Ubuntu 22.04+ tested. ^dep-os
- External: `sudo` access (driver install requires root). ^dep-sudo

## Install

This SEED is implementation-defined for non-Linux / non-NVIDIA platforms. On macOS, AMD, or Windows: refer to autoresearch's [notable forks](https://github.com/karpathy/autoresearch#notable-forks) and substitute that fork's CUDA-equivalent install steps. On Linux + NVIDIA, follow the steps below.

### Step 0 — Detect GPU

```bash
lspci | grep -i nvidia                    # MUST list at least one NVIDIA device
```

If empty, this machine has no NVIDIA GPU; abort and use a CPU-only fork (or stop installing the autoresearch SEED).

### Step 1 — Install NVIDIA driver

On Ubuntu 22.04+:

```bash
sudo apt update
sudo apt install -y nvidia-driver-535     # or newer matching the kernel
```

A reboot MAY be required before `nvidia-smi` works.

### Step 2 — Install CUDA toolkit (OPTIONAL)

The autoresearch dependency stack pulls CUDA via PyTorch wheels at `uv sync` time, so a system-wide CUDA toolkit is OPTIONAL for autoresearch specifically. Install it only if other SEEDs in your tree need `nvcc` / system CUDA libraries:

```bash
sudo apt install -y nvidia-cuda-toolkit
```

### Step 3 — Verify driver loads

```bash
nvidia-smi
```

The output MUST list the GPU, driver version, and CUDA-runtime version. If it errors with `NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver`, reboot and retry.

## Verify

```bash
nvidia-smi | grep -qE 'Driver Version: [0-9]+'    # driver loaded
lspci | grep -qi nvidia                            # GPU present
```

Both MUST succeed.

## Open

- ROCm (AMD) and MPS (Apple Silicon) variants are out-of-scope; this SEED targets NVIDIA + Linux only. ^o-platform
- Driver/toolkit version compatibility with PyTorch is implementation-defined; autoresearch's `uv sync` resolves the PyTorch wheel that matches the installed driver, but exotic driver versions MAY require pinning a specific PyTorch wheel manually. ^o-version-compat
- Multi-GPU and distributed training are out-of-scope for autoresearch (single GPU only by design); no multi-GPU configuration is needed. ^o-multi-gpu
^open
