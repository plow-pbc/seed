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

# Fence-toggle helpers: strip lines inside ```...``` or ~~~...~~~ fenced
# code blocks (CommonMark allows 0-3 leading spaces). Two patterns
# combined with || avoid ERE alternation inside /.../, which mawk does
# not support.
h1s_of() {
  awk '/^ {0,3}```/ || /^ {0,3}~~~/ {f=!f; next} !f && /^# [^#]/' "$1"
}
h2s_of() {
  awk '/^ {0,3}```/ || /^ {0,3}~~~/ {f=!f; next} !f && /^## /' "$1"
}
# Extract the body of the `# Purpose` H1: lines between the H1 and the
# next heading, excluding fenced code blocks and blank lines.
purpose_body_of() {
  awk '
    /^ {0,3}```/ || /^ {0,3}~~~/ {fence=!fence; next}
    fence { next }
    /^# Purpose$/ { in_p=1; next }
    /^#/ { in_p=0 }
    in_p && NF { print }
  ' "$1"
}

# 1. README has ## Purpose outside fenced code blocks.
h2s_of README.md | grep -qx '## Purpose'

# 2. Root SEED.md declares RFC 2119 (outside fenced code blocks).
h2s_of SEED.md | grep -qx '## Normative Language'

# 3. Tree structural check: every SEED.md has one H1 (# Purpose) whose
#    body is exactly one non-blank line containing a README#Purpose
#    wikilink, the four required H2s in order, and a full H2 sequence
#    that's a subsequence of canonical.
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
  pb=$(purpose_body_of "$f")
  test "$(echo "$h1" | wc -l)" -eq 1 && test "$h1" = "# Purpose" \
    || { echo "FAIL H1 not exactly '# Purpose': $f"; fail=1; continue; }
  test "$(echo "$pb" | wc -l)" -eq 1 \
    || { echo "FAIL Purpose body not a single non-blank line: $f"; fail=1; continue; }
  echo "$pb" | grep -qE 'README#Purpose' \
    || { echo "FAIL Purpose body missing README#Purpose wikilink: $f"; fail=1; continue; }
  echo "$h2" | grep -E '^## (Dependencies|Objects|Actions|Verify)$' | diff - \
       <(printf '## Dependencies\n## Objects\n## Actions\n## Verify\n') >/dev/null \
    || { echo "FAIL required H2s missing or out of order: $f"; fail=1; continue; }
  echo "$h2" | awk -v canon="$canonical" '
    BEGIN { n = split(canon, c, "\n"); i = 1 }
    { while (i <= n && c[i] != $0) i++; if (i > n) exit 1; i++ }
  ' || { echo "FAIL H2 sequence not a subsequence of canonical (or has duplicates): $f"; fail=1; continue; }
done

test "$fail" = "0" && echo "tree conforms"
