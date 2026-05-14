#!/usr/bin/env bash
# Acceptance test for wikilinks across the convention's markdown surfaces
# (root SEED + every ref/skills/<skill>/{README,SEED,SKILL}.md). Each
# [[<path>#<anchor>]] MUST resolve to an existing file, and a `^block-id`
# anchor MUST exist in that file. Empty paths ([[#<anchor>]]) are treated
# as same-file references. Catches stale anchor references and wrong
# relative depth that would otherwise only surface at install time.

set -eu
shopt -s nullglob

here=$(cd "$(dirname "$0")/.." && pwd)
fail=0

# Files with wikilinks worth checking: root convention + every sub-SEED
# markdown file. The list always starts with the literal root SEED.md, so
# nullglob can drop the skill globs without ever yielding an empty list.
files=(
  "$here/SEED.md"
  "$here"/ref/skills/*/README.md
  "$here"/ref/skills/*/SEED.md
  "$here"/ref/skills/*/SKILL.md
)

for file in "${files[@]}"; do
  file_dir=$(dirname "$file")
  while read -r raw; do
    link=${raw#[[}; link=${link%]]}
    path=${link%%#*}
    anchor=${link#*#}
    # Empty path = same-file reference (e.g. [[#^seed-grammar]]).
    if [ -z "$path" ]; then
      target=$file
    else
      [[ "$path" == *.md ]] || path="$path.md"
      # Resolve <path> relative to the file's directory by cd-ing through it;
      # the file's parent directory must exist for the link to be resolvable.
      if ! target=$( cd "$file_dir" && cd "$(dirname -- "$path")" 2>/dev/null \
                     && printf '%s/%s' "$PWD" "$(basename -- "$path")" ); then
        echo "FAIL: $file → $raw — parent directory of '$path' does not exist"
        fail=1
        continue
      fi
      if [[ ! -f "$target" ]]; then
        echo "FAIL: $file → $raw resolves to missing file: $target"
        fail=1
        continue
      fi
    fi
    if [[ "$anchor" == ^* ]]; then
      # Block IDs live at end-of-line. Match the anchor as a complete
      # token (preceded by SOL or whitespace, followed by trailing
      # whitespace or EOL) — not as a substring — so `^act-install`
      # does NOT satisfy a reference to `^act-install-modes`.
      escaped="${anchor//\^/\\^}"
      if ! grep -qE "(^|[[:space:]])${escaped}[[:space:]]*\$" "$target"; then
        echo "FAIL: $file → $raw references missing block-id $anchor in $target"
        fail=1
      fi
    fi
    # Strip single-backtick code spans before grepping for [[...]] — wikilink
    # forms quoted as examples (e.g. `[[<child>/SEED#Purpose]]` in the spec)
    # aren't real cross-references and shouldn't be resolved.
  done < <(awk '{ while (match($0, /`[^`]*`/)) $0 = substr($0,1,RSTART-1) substr($0,RSTART+RLENGTH); print }' "$file" | grep -oE '\[\[[^]]+\]\]' | sort -u)
done

test "$fail" = "0" && echo "ok"
