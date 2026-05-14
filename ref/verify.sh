#!/usr/bin/env bash
# Reference deterministic implementation of the SEED ## Verify prompts.
# The natural-language prompts in the parent SEED.md's ## Verify section
# are normative; this script runs the same checks as bash so CI and
# non-AI callers have a deterministic exit code.
#
# Run from the repo root: `bash ref/verify.sh`
# Exit zero if the SEED tree conforms.

set -eu

# Verify a SEED tree. Default target is the convention repo (the parent of
# this script), so existing callers (`bash ref/verify.sh` from repo root)
# work unchanged. Pass a target dir as $1 to verify a different SEED tree —
# used by /seed-create to self-verify a newly authored SEED.
cd -- "${1:-$(dirname "$0")/..}"

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
# Pipe-separated so the value survives `awk -v` across awk variants
# (BSD awk on macOS rejects multi-line -v values).
canonical='## Normative Language|## Dependencies|## Objects|## Actions|## Verify|## Feedback|## Open|## Non-Goals'

fail=0
# NUL-delimited find loop so SEED.md paths containing spaces or newlines
# survive (a target dir like '/tmp/my seed' would split under for-in $(find)).
while IFS= read -r -d '' f; do
  h1=$(h1s_of "$f")
  h2=$(h2s_of "$f")
  pb=$(purpose_body_of "$f")
  test "$(echo "$h1" | wc -l)" -eq 1 && test "$h1" = "# Purpose" \
    || { echo "FAIL H1 not exactly '# Purpose': $f"; fail=1; continue; }
  test "$(echo "$pb" | wc -l)" -eq 1 \
    || { echo "FAIL Purpose body not a single non-blank line: $f"; fail=1; continue; }
  # Body must be ONLY a sibling-or-ancestor README#Purpose wikilink, per
  # SEED.md ## Verify check 3. The recommended `> See [[...]].` blockquote
  # form is the only allowed prose decoration; anything else is "description"
  # which the contract forbids.
  echo "$pb" | grep -qE '^(> *)?(See *)?\[\[[A-Za-z0-9_./-]*README#Purpose\]\]\.?$' \
    || { echo "FAIL Purpose body not the canonical README#Purpose wikilink form: $f"; fail=1; continue; }
  echo "$h2" | grep -E '^## (Dependencies|Objects|Actions|Verify)$' | diff - \
       <(printf '## Dependencies\n## Objects\n## Actions\n## Verify\n') >/dev/null \
    || { echo "FAIL required H2s missing or out of order: $f"; fail=1; continue; }
  echo "$h2" | awk -v canon="$canonical" '
    BEGIN { n = split(canon, c, "|"); i = 1 }
    { while (i <= n && c[i] != $0) i++; if (i > n) exit 1; i++ }
  ' || { echo "FAIL H2 sequence not a subsequence of canonical (or has duplicates): $f"; fail=1; continue; }
done < <(find . -path './.git' -prune -o -name 'SEED.md' -print0)

test "$fail" = "0" && echo "tree conforms"
