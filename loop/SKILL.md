---
name: loop
description: Run the self-correcting build loop, alternating build and review until the feature list passes clean or a stopping condition is hit. Use this when the user says "/loop", "run the loop", "start building", or wants the project built autonomously from an existing spec and feature list. Always respect the iteration cap and per-feature error budget in loop-config.json, and stop for a human rather than grinding indefinitely.
---

# loop

This orchestrates the whole build. It alternates the build step and the review step against `feature_list.json` until either everything passes or a stopping condition is reached. It exists so the build runs itself while staying controllable: bounded, recoverable across context windows, and willing to stop and ask for help instead of looping forever.

## Preconditions

Before starting, confirm `specs/<name>.md`, `feature_list.json`, `loop-config.json`, `init.sh` and `verify.sh` all exist. If any are missing, stop and tell the user to run `/spec` then `/init` first. Do not start a loop without ground truth to grade against.

## The cycle

Repeat:

1. Run the `build` step: orient from progress log and git, pick one not-yet-passing feature under its attempt budget, build only that, commit, update progress.
2. Run the `review` step: run `verify_cmd`, grade feature by feature by execution, flip genuinely-passing features to true, write specific fixes for failures.
3. Commit and update `claude-progress.txt` at the end of every cycle, so progress survives a context-window break and the next cycle can resume cleanly.

## Stopping conditions (check every cycle)

Stop and report when any of these is true. Do not keep going past them.

- All features have `passes: true`. The build is done. Report the final state.
- The cycle count reaches `max_iterations`. Stop and report what passes, what remains, and the most useful next step. Do not silently raise the cap.
- A feature reaches `error_budget_per_feature` attempts without passing. Stop and surface that feature specifically: a feature that keeps failing usually means the spec is wrong, a dependency is missing, or the fix is breaking something else. This is a signal for a human, not a reason to retry forever.
- The same failure repeats across cycles with no progress, or a fix for one feature keeps breaking another. Cascading failures waste tokens and rarely resolve themselves. Stop and explain the conflict.

## Staying in control

- Before a long run, give the user a rough sense of expected cycles and cost, so an unbounded run is a deliberate choice rather than a surprise.
- Prefer many short controlled cycles over one giant uninterrupted run. A failure in cycle 3 should not cost the work of cycles 4 through 10.
- Keep the loop a single straightforward sequence of build then review. Do not spin up extra agents or parallel tracks unless the simple version has demonstrably fallen short; simplicity is what keeps it debuggable.

When you stop for any reason, leave the repo clean and committed and give the user a plain summary of where things stand and what you would do next.
