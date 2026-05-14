#!/usr/bin/env bash
# Acceptance test for ref/verify.sh's target-dir mode (the self-verify
# gate used by /seed-create). Uses the convention repo itself as the
# canonical conforming fixture; builds only the malformed and
# spaced-path siblings ad-hoc from the repo's own files.

set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

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

# Regression: SEED.md files inside paths containing spaces must survive
# the find walk (verify.sh uses a NUL-delimited loop). The sub-SEED's
# Purpose wikilink resolves to the parent's README (sibling-or-ancestor),
# so adjust it from `[[README#Purpose]]` to `[[../README#Purpose]]`.
mkdir -p "$tmp/has space/sub dir"
cp "$here/README.md" "$tmp/has space/README.md"
cp "$here/SEED.md" "$tmp/has space/SEED.md"
sed 's|\[\[README#Purpose\]\]|[[../README#Purpose]]|' "$here/SEED.md" \
  >"$tmp/has space/sub dir/SEED.md"
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
sed 's|\[\[README#Purpose\]\]|[[../README#Purpose]]|' "$here/SEED.md" \
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
# is deliberately not created.
cp "$here/SEED.md" "$tmp/missing-readme/orphan/SEED.md"
if bash "$here/ref/verify.sh" "$tmp/missing-readme" >/dev/null 2>&1; then
  echo "FAIL: SEED.md pointing to nonexistent README accepted"
  exit 1
fi

echo "ok"
