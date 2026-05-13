default: test

# Acceptance test for ref/verify.sh — runs both the no-arg form
# (verifies this convention repo) and the target-dir form against
# a fixture pair.
test:
    bash ref/verify.sh >/dev/null
    bash ref/test_verify.sh
