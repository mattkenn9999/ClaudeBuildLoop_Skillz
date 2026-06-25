---
name: build
description: Build one feature from the feature list, working incrementally and leaving the environment clean. Use this when the user says "/build", when they want to make progress on a project that already has feature_list.json and verify.sh, or as the build half of a build/review loop. Always orient yourself from the progress log and git history first, because each session starts with no memory of the last, and always build only a single feature per run to avoid running out of context mid-implementation.
---

# build

This is the build half of the loop. Its job is to make real, incremental progress: pick one feature, implement exactly that, leave the codebase in a clean committed state, and hand off cleanly to the review step. Do not try to build everything at once. Doing too much in one pass is the main reason agents run out of context and leave a half-finished mess.

## Why work one feature at a time

Each session has a finite context window. If you attempt several features at once you tend to run out of room mid-implementation, leaving the next session to guess at what happened. One feature per run, fully committed, keeps the project always in a recoverable state and lets progress compound across sessions.

## What to do

### 1. Get your bearings (always do this first)

Start every run by orienting, because you begin with no memory of previous sessions:

1. Run `pwd` to confirm the working directory. You can only edit files here.
2. Read `claude-progress.txt` and `git log --oneline -20` to see what was recently done.
3. Read `loop-config.json` and `feature_list.json`.
4. Run `init_cmd` to start the app, then run a quick smoke test of basic functionality (for a UI, drive it through the browser).

If that smoke test shows the app is broken, fix that before anything else. Starting a new feature on top of a broken base only makes things worse. Treat restoring a working state as the work for this run if needed.

### 2. Choose one feature

From `feature_list.json`, pick the highest-priority feature where `passes` is false and `attempts` is below `error_budget_per_feature`. That is your single target for this run. Do not pick more than one. If every remaining unsolved feature is already at its attempt budget, do not keep trying: stop and tell the user which features are stuck and why, so a human can step in.

### 3. Build exactly that feature

- Implement what the feature describes, and nothing else. No extra features, no speculative abstractions, no refactoring of unrelated code, no requirements you invented.
- Increment that feature's `attempts` by one in `feature_list.json`.
- Do not edit any other feature's `description`, `steps`, or `passes`. Changing or weakening the feature list to make things look done defeats the entire loop.

### 4. Self-check, then commit

- Run `verify_cmd`. Use the result to fix obvious breakage now, while you have the context.
- Do not set `passes` to true yourself. Scoring is the review step's job, and keeping building and grading separate is what makes the loop reliable. Record what you did in the feature's `last_result` field instead.
- Commit your work to git with a descriptive message naming the feature id. Update `claude-progress.txt` with a short note: what you built, current state, anything the next agent should know.
- When you update `claude-progress.txt`, keep its standing sections true, do not only append to the log. If a section describes the project as a bare scaffold or a file as a placeholder and that is no longer the case, correct it. A cold-start agent reads those standing sections as current truth, so a stale "what exists now" section can wrongly convince the next session that little has been built.

### 5. Hand off

Leave the repo clean and committed. Tell the user (or the loop) that the feature is built and ready for `/review`. Do not move on to a second feature in the same run.
