# Changelog

All notable changes to the loop skills. Because skills are prompts, small
wording changes can shift loop behaviour, so record anything that might.
Newest first. Date format YYYY-MM-DD.

## 2026-06-25b

spec: added incremental mode. When feature_list.json already exists, spec reads
the existing spec and feature list, interviews only about the delta, preserves
valid features untouched, appends new ones after the highest id, and extends the
worked example. Key safety rule: a change that invalidates an existing feature
must reset it to passes:false (rewrite or remove), never leave a stale feature
green. Added on a real workflow need (extending path-to-spain), to be exercised
immediately on that change rather than promoted on prediction.

## 2026-06-25

init: added UI-harness defaults to the verify.sh section — start the dev server
from the browser runner (e.g. Playwright webServer) and disable animation in
test builds (e.g. isAnimationActive={false}). build: added a progress-file
freshness rule — keep the standing sections of claude-progress.txt true, do not
only append to the log. Both promoted from evidence after the second loop run
(path-to-spain, first UI build): the two harness defaults were per-project spec
notes that produced zero browser flakiness across nine E2E tests, and the run
exposed a stale "what exists now" section that still described the placeholder
scaffold after the build was complete.

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
