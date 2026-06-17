---
name: review
description: Verify a build against its feature list by actually running it, then grade each feature and write specific fixes for what fails. Use this when the user says "/review", after a /build run, or as the review half of a build/review loop. Always verify by execution, never by re-reading code, because the most common failure is marking a feature complete when it does not actually work end to end.
---

# review

This is the review half of the loop and the authority on what counts as done. Its job is to grade the build against `feature_list.json` using ground truth from actually running the checks, flip the status of features that genuinely work, and hand back precise fixes for the ones that do not. Building and grading are different acts: separating them is what turns blind editing into directed search towards a passing state.

## Why you must run things, not just read them

The single most common failure mode is declaring a feature complete without verifying it end to end. Re-reading the code and the spec and concluding "this looks right" is exactly that failure. A unit test passing or a curl returning 200 is not the same as the user-facing behaviour working. So this step runs the real checks and, for anything with a user interface, exercises it as a user would.

## What to do

### 1. Run the verification harness

- Read `loop-config.json` and `feature_list.json`.
- Run `verify_cmd`. This runs the linter, type-checker, tests, and for a UI the browser-driven end-to-end checks. Capture the actual output.
- Rules-based feedback like lint and type errors is the strongest signal available, so read it carefully and use the exact failures, not your impression of the code.

### 2. Grade feature by feature

Go through `feature_list.json` one feature at a time. For each feature with `passes: false`, walk its `steps` and confirm by execution whether the behaviour actually happens. For a UI feature this means driving the browser through the steps and observing the result, including what is visible on screen, not just what the code suggests should happen.

- Set `passes` to true only for features you have actually confirmed work end to end. When in genuine doubt, leave it false.
- For each feature that fails, write into its `last_result` a specific, actionable description of what failed and the concrete fix needed, naming the failing step. "Login is broken" is useless. "Step 3 fails: submitting the form with a valid password returns a 500 because the auth handler is not awaited in api/login.ts" is useful.

### 3. Protect the feature list

Never edit or remove a feature's `description` or `steps` to make the build pass, and never weaken or delete a test for the same reason. That would hide missing or broken functionality, which is the opposite of the point. If a feature is genuinely wrong or impossible as written, do not silently change it: flag it to the user and explain why.

### 4. Report and hand off

Summarise plainly:

- which features now pass, which still fail
- for each failure, the exact next action (this is what the build step will pick up)
- whether any feature is approaching or at its attempt budget and may need a human

If every feature passes, say so clearly and stop: the build is done. Otherwise the loop continues with another `/build` pass against the failures you just wrote.
