#!/usr/bin/env bash
# Acceptance test for ref/verify.sh's target-dir mode (the self-verify
# gate used by /seed-create). Uses the convention repo itself as the
# canonical conforming fixture; builds only the malformed and
# spaced-path siblings ad-hoc from the repo's own files.

set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Build a conforming sub-SEED from the repo's root SEED.md: swap the
# Purpose wikilink target to point at the ancestor README, and strip
# ## Normative Language (sub-SEEDs inherit RFC 2119 per ^seed-grammar).
sub_seed_from_root() {
  local wikilink=$1
  sed "s|\\[\\[README#Purpose\\]\\]|[[$wikilink]]|" "$here/SEED.md" | awk '
    /^## Normative Language$/ { skip=1; next }
    /^## / && skip { skip=0 }
    !skip
  '
}

# Positive: target-dir mode accepts this convention repo.
bash "$here/ref/verify.sh" "$here" >/dev/null \
  || { echo "FAIL: conforming repo rejected via target-dir mode"; exit 1; }

# Negative: a copy of the repo's SEED.md with `## Verify` stripped
# must be rejected.
mkdir "$tmp/bad"
cp "$here/README.md" "$tmp/bad/README.md"
awk '/^## Verify$/{exit} {print}' "$here/SEED.md" >"$tmp/bad/SEED.md"

if bash "$here/ref/verify.sh" "$tmp/bad" >/dev/null 2>&1; then
  echo "FAIL: malformed fixture (missing ## Verify) accepted"
  exit 1
fi

# Negative: a README without `## Purpose` must be rejected (verify.sh
# check 1). /seed-create depends on this gate to catch a draft where
# the README's marketing prose was renamed or stripped.
mkdir "$tmp/bad-readme"
awk '/^## Purpose$/{skip=1} /^##/ && !/^## Purpose$/{skip=0} !skip' "$here/README.md" \
  >"$tmp/bad-readme/README.md"
cp "$here/SEED.md" "$tmp/bad-readme/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-readme" >/dev/null 2>&1; then
  echo "FAIL: README without ## Purpose accepted"
  exit 1
fi

# Negative: a root SEED.md without `## Normative Language` must be
# rejected (verify.sh check 2). /seed-create depends on this gate to
# catch a draft that skipped the RFC 2119 declaration.
mkdir "$tmp/bad-normative"
cp "$here/README.md" "$tmp/bad-normative/README.md"
awk '/^## Normative Language$/{skip=1} /^##/ && !/^## Normative Language$/{skip=0} !skip' \
  "$here/SEED.md" >"$tmp/bad-normative/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-normative" >/dev/null 2>&1; then
  echo "FAIL: root SEED.md without ## Normative Language accepted"
  exit 1
fi

# Regression: SEED.md files inside paths containing spaces must survive
# the find walk (verify.sh uses a NUL-delimited loop). The sub-SEED's
# Purpose wikilink resolves to the parent's README (sibling-or-ancestor),
# and the sub-SEED must inherit ## Normative Language (omit, don't
# re-declare).
mkdir -p "$tmp/has space/sub dir"
cp "$here/README.md" "$tmp/has space/README.md"
cp "$here/SEED.md" "$tmp/has space/SEED.md"
sub_seed_from_root '../README#Purpose' >"$tmp/has space/sub dir/SEED.md"
bash "$here/ref/verify.sh" "$tmp/has space" >/dev/null \
  || { echo "FAIL: SEED.md in spaced subdir rejected (find walk split)"; exit 1; }

# Regression: a relative target path beginning with `-` must not be
# parsed as a flag by verify.sh's `cd` (uses `cd --`).
(cd "$tmp" && mkdir -- -seed && cp -- "$here/README.md" "$here/SEED.md" -seed/ \
  && bash "$here/ref/verify.sh" -seed >/dev/null) \
  || { echo "FAIL: relative target path starting with '-' rejected"; exit 1; }

# Negative: a `# Purpose` body with extra description prose around the
# wikilink must be rejected. The contract says the body is ONLY the
# sibling-or-ancestor README#Purpose wikilink (`> See [[...]].` form
# allowed); anything more is "description".
mkdir "$tmp/bad-purpose"
cp "$here/README.md" "$tmp/bad-purpose/README.md"
awk '
  BEGIN { swap=0 }
  /^> See \[\[README#Purpose\]\]\.$/ && !swap {
    print "This SEED is special. See [[README#Purpose]] for more."; swap=1; next
  }
  { print }
' "$here/SEED.md" >"$tmp/bad-purpose/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-purpose" >/dev/null 2>&1; then
  echo "FAIL: SEED.md with extra prose in # Purpose body accepted"
  exit 1
fi

# Negative: a tree where the root SEED.md is valid but a nested
# SEED.md is malformed must be rejected (verify walks the whole tree,
# not just the root). The malformed sub-SEED has `## Verify` stripped
# AND uses `[[../README#Purpose]]` so it fails on the H2-sequence
# check, not the (intentionally separate) missing-README check below.
mkdir -p "$tmp/bad-child/sub dir"
cp "$here/README.md" "$tmp/bad-child/README.md"
cp "$here/SEED.md" "$tmp/bad-child/SEED.md"
sub_seed_from_root '../README#Purpose' \
  | awk '/^## Verify$/{exit} {print}' >"$tmp/bad-child/sub dir/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-child" >/dev/null 2>&1; then
  echo "FAIL: tree with malformed sub-SEED accepted"
  exit 1
fi

# Negative: a nested SEED.md whose Purpose wikilink resolves to a
# nonexistent README must be rejected. The wikilink contract is
# sibling-or-ancestor README#Purpose; a string-match-only check would
# print "tree conforms" for an orphan SEED.md.
mkdir -p "$tmp/missing-readme/orphan"
cp "$here/README.md" "$tmp/missing-readme/README.md"
cp "$here/SEED.md" "$tmp/missing-readme/SEED.md"
# Sub-SEED's `[[README#Purpose]]` resolves to orphan/README.md, which
# is deliberately not created. Strip Normative Language so the failure
# is on the missing-README contract, not the root-only-Normative gate.
sub_seed_from_root 'README#Purpose' >"$tmp/missing-readme/orphan/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/missing-readme" >/dev/null 2>&1; then
  echo "FAIL: SEED.md pointing to nonexistent README accepted"
  exit 1
fi

# Negative: descendant prefix ([[child/README#Purpose]]) violates
# sibling-or-ancestor even if the referenced file exists on disk.
mkdir -p "$tmp/bad-descendant/child"
cp "$here/README.md" "$tmp/bad-descendant/README.md"
cp "$here/README.md" "$tmp/bad-descendant/child/README.md"
# Root SEED.md with a descendant-prefix wikilink: tests root-level
# behavior, so the file must stay a valid root (keep Normative Language).
sed 's|\[\[README#Purpose\]\]|[[child/README#Purpose]]|' "$here/SEED.md" \
  >"$tmp/bad-descendant/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-descendant" >/dev/null 2>&1; then
  echo "FAIL: descendant-prefix wikilink ([[child/README#Purpose]]) accepted"
  exit 1
fi

# Negative: cousin prefix ([[../sibling/README#Purpose]]) violates
# sibling-or-ancestor — "sibling of an ancestor" is neither. Build a
# tree where the sub-SEED's wikilink resolves to a real file under
# `../sibling/README.md` and assert verify rejects it.
mkdir -p "$tmp/bad-cousin/sibling" "$tmp/bad-cousin/branch"
cp "$here/README.md" "$tmp/bad-cousin/README.md"
cp "$here/README.md" "$tmp/bad-cousin/sibling/README.md"
cp "$here/SEED.md" "$tmp/bad-cousin/SEED.md"
sub_seed_from_root '../sibling/README#Purpose' >"$tmp/bad-cousin/branch/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-cousin" >/dev/null 2>&1; then
  echo "FAIL: cousin-prefix wikilink ([[../sibling/README#Purpose]]) accepted"
  exit 1
fi

# Negative: a wikilink to a more-distant ancestor README when a closer
# one exists must be rejected. The contract says "*closest* sibling-or-
# ancestor"; without this check, [[../../README#Purpose]] would pass
# whenever ../../README.md exists, silently skipping ../README.md.
mkdir -p "$tmp/bad-skip-readme/close/sub"
cp "$here/README.md" "$tmp/bad-skip-readme/README.md"
cp "$here/README.md" "$tmp/bad-skip-readme/close/README.md"
cp "$here/SEED.md" "$tmp/bad-skip-readme/SEED.md"
sub_seed_from_root '../../README#Purpose' >"$tmp/bad-skip-readme/close/sub/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-skip-readme" >/dev/null 2>&1; then
  echo "FAIL: sub-SEED skipping closer README ($tmp/bad-skip-readme/close/README.md) accepted"
  exit 1
fi

# Negative: a nested SEED.md MUST NOT re-declare ## Normative Language
# (it inherits from the root per ^seed-grammar). Build a tree where the
# sub-SEED is a literal copy of the root SEED.md (with just the wikilink
# adjusted) — keeping Normative Language — and assert verify rejects it.
mkdir -p "$tmp/bad-nested-normative/sub"
cp "$here/README.md" "$tmp/bad-nested-normative/README.md"
cp "$here/SEED.md" "$tmp/bad-nested-normative/SEED.md"
sed 's|\[\[README#Purpose\]\]|[[../README#Purpose]]|' "$here/SEED.md" \
  >"$tmp/bad-nested-normative/sub/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/bad-nested-normative" >/dev/null 2>&1; then
  echo "FAIL: nested SEED.md re-declaring ## Normative Language accepted"
  exit 1
fi

echo "ok"
