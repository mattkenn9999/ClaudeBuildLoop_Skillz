# Changelog

All notable changes to the loop skills. Because skills are prompts, small
wording changes can shift loop behaviour, so record anything that might.
Newest first. Date format YYYY-MM-DD.

## 2026-06-22

spec: added "Three checks that keep features verifiable" (data pinned in the
feature that produces it, process-boundary contracts verified by running the
process, inner functions kept injectable when the product contract is fixed).
Promoted from evidence after the first real loop run (name-screener), where all
three were load-bearing: the seeded tie pair made the tie feature constructible,
subprocess tests verified the exit-code contract, and an injectable loader path
made the watchlist error cases testable without moving the committed file.

## 2026-06-17

Initial set of five skills.

- spec: interview, then write specs/<name>.md plus a structured feature_list.json
- init: scaffold init.sh, verify.sh, loop-config.json, git repo and progress log, once
- build: orient from progress and git, build one feature, commit, leave clean
- review: run verify.sh, grade feature by feature by execution, write named fixes
- loop: alternate build and review with an iteration cap and per-feature error budget
