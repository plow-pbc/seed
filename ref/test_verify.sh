#!/usr/bin/env bash
# Acceptance test for ref/verify.sh's target-dir mode (the self-verify
# gate used by /seed-create). Builds a minimal conforming SEED, then a
# malformed copy with `## Verify` stripped; asserts accept/reject.

set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir "$tmp/ok" "$tmp/bad"
cat >"$tmp/ok/README.md" <<'MD'
# Fixture

## Purpose

Minimal conforming SEED tree.
MD
cat >"$tmp/ok/SEED.md" <<'MD'
# Purpose

> See [[README#Purpose]].

## Normative Language

Inherited from RFC 2119.

## Dependencies

(none)

## Objects

(none)

## Actions

(none)

## Verify

(none)
MD

cp "$tmp/ok/README.md" "$tmp/bad/README.md"
awk '/^## Verify$/{exit} {print}' "$tmp/ok/SEED.md" >"$tmp/bad/SEED.md"

# Sub-SEED with `## Normative Language` should be rejected (root-only per
# ^seed-grammar). Build a tree where the child SEED re-declares Normative
# Language; the conforming-parent + violating-child shape exercises the
# tree walk's per-file root-vs-sub check.
mkdir -p "$tmp/sub-nl/child"
cp "$tmp/ok/README.md" "$tmp/sub-nl/README.md"
cp "$tmp/ok/SEED.md"   "$tmp/sub-nl/SEED.md"
cp "$tmp/ok/README.md" "$tmp/sub-nl/child/README.md"
cp "$tmp/ok/SEED.md"   "$tmp/sub-nl/child/SEED.md"

bash "$here/ref/verify.sh" "$tmp/ok" >/dev/null \
  || { echo "FAIL: conforming fixture rejected"; exit 1; }

if bash "$here/ref/verify.sh" "$tmp/bad" >/dev/null 2>&1; then
  echo "FAIL: malformed fixture (missing ## Verify) accepted"
  exit 1
fi

if bash "$here/ref/verify.sh" "$tmp/sub-nl" >/dev/null 2>&1; then
  echo "FAIL: sub-SEED with ## Normative Language accepted"
  exit 1
fi

echo "ok"
