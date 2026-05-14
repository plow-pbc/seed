default: test

# Acceptance tests for ref/verify.sh (no-arg + target-dir) and the
# skill wikilink resolver (catches stale ^anchors and wrong relative
# depth between SKILL.md and SEED.md).
test:
    bash ref/verify.sh >/dev/null
    bash ref/test_verify.sh
    bash ref/test_skill_links.sh
