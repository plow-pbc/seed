#!/usr/bin/env bash
# Acceptance test for wikilinks in ref/skills/*/SKILL.md. Each
# [[<path>#<anchor>]] MUST resolve to an existing file, and a `^block-id`
# anchor MUST exist in that file. Catches stale anchor references and
# wrong relative depth that would otherwise only surface at install time.

set -eu
shopt -s nullglob

here=$(cd "$(dirname "$0")/.." && pwd)
fail=0

# Materialize the glob so a zero-match expansion fails loud instead of
# iterating over the literal raw pattern.
skills=("$here"/ref/skills/*/SKILL.md)
if [ ${#skills[@]} -eq 0 ]; then
  echo "FAIL: no ref/skills/*/SKILL.md files matched — refusing to print ok"
  exit 1
fi

for skill in "${skills[@]}"; do
  skill_dir=$(dirname "$skill")
  while read -r raw; do
    link=${raw#[[}; link=${link%]]}
    path=${link%%#*}
    anchor=${link#*#}
    [[ "$path" == *.md ]] || path="$path.md"
    # Resolve <path> relative to the skill's directory by cd-ing through it;
    # the file's parent directory must exist for the link to be resolvable.
    if ! target=$( cd "$skill_dir" && cd "$(dirname -- "$path")" 2>/dev/null \
                   && printf '%s/%s' "$PWD" "$(basename -- "$path")" ); then
      echo "FAIL: $skill → $raw — parent directory of '$path' does not exist"
      fail=1
      continue
    fi
    if [[ ! -f "$target" ]]; then
      echo "FAIL: $skill → $raw resolves to missing file: $target"
      fail=1
      continue
    fi
    if [[ "$anchor" == ^* ]] && ! grep -qF "$anchor" "$target"; then
      echo "FAIL: $skill → $raw references missing block-id $anchor in $target"
      fail=1
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$skill" | sort -u)
done

test "$fail" = "0" && echo "ok"
