#!/usr/bin/env bash
# Reference deterministic implementation of the SEED ## Verify prompts.
# The natural-language prompts in the parent SEED.md's ## Verify section
# are normative; this script runs the same checks as bash so CI and
# non-AI callers have a deterministic exit code.
#
# Run from the repo root: `bash ref/verify.sh`
# Exit zero if the SEED tree conforms.

set -eu

cd "$(dirname "$0")/.."

# Fence-toggle helper: strip lines inside ```...``` or ~~~...~~~ fenced code
# blocks (CommonMark allows 0-3 leading spaces). Two patterns combined with
# || avoid ERE alternation inside /.../, which mawk does not support.
h1s_of() {
  awk '/^ {0,3}```/ || /^ {0,3}~~~/ {f=!f; next} !f && /^# [^#]/' "$1"
}
h2s_of() {
  awk '/^ {0,3}```/ || /^ {0,3}~~~/ {f=!f; next} !f && /^## /' "$1"
}

# 1. README has ## Purpose outside fenced code blocks.
h2s_of README.md | grep -qx '## Purpose'

# 2. Root SEED.md has exactly one H1, which is "# Purpose".
root_h1=$(h1s_of SEED.md)
test "$(echo "$root_h1" | wc -l)" -eq 1
test "$root_h1" = "# Purpose"

# 3. Root SEED.md declares RFC 2119 (outside fenced code blocks).
h2s_of SEED.md | grep -qx '## Normative Language'

# 4. Tree structural check: every SEED.md has one H1 (# Purpose), a
#    README#Purpose back-reference in the first 3 lines, the four required
#    H2s in order, and the full H2 sequence is a subsequence of canonical.
canonical='## Normative Language
## Dependencies
## Objects
## Actions
## Verify
## Feedback
## Open
## Non-Goals'

fail=0
for f in $(find . -path './.git' -prune -o -name 'SEED.md' -print); do
  h1=$(h1s_of "$f")
  h2=$(h2s_of "$f")
  test "$(echo "$h1" | wc -l)" -eq 1 && test "$h1" = "# Purpose" \
    || { echo "FAIL H1 not exactly '# Purpose': $f"; fail=1; continue; }
  head -3 "$f" | grep -q 'README#Purpose' \
    || { echo "FAIL no README#Purpose back-ref: $f"; fail=1; continue; }
  echo "$h2" | grep -E '^## (Dependencies|Objects|Actions|Verify)$' | diff - \
       <(printf '## Dependencies\n## Objects\n## Actions\n## Verify\n') >/dev/null \
    || { echo "FAIL required H2s missing or out of order: $f"; fail=1; continue; }
  echo "$h2" | awk -v canon="$canonical" '
    BEGIN { n = split(canon, c, "\n"); i = 1 }
    { while (i <= n && c[i] != $0) i++; if (i > n) exit 1 }
  ' || { echo "FAIL H2 sequence not a subsequence of canonical: $f"; fail=1; continue; }
done

test "$fail" = "0" && echo "tree conforms"
