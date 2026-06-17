# FC build loop: a self-correcting Claude Code loop

Five skills that turn Claude Code into a loop which specs, scaffolds, builds, and verifies software incrementally, until the feature list passes clean or it hits a deliberate stop.

This is an upgraded version of the common three-prompt loop. The differences are the things that make a loop survive past one context window and stay controllable: verification by execution rather than re-reading, persistent state across sessions, one feature at a time, and explicit stopping conditions.

## The five skills

1. `spec` turns an idea into `specs/<name>.md` plus a structured `feature_list.json` (the spine: end-to-end, checkable features).
2. `init` runs once to scaffold the environment: `init.sh`, `verify.sh` (the ground-truth check), `loop-config.json`, a git repo, and `claude-progress.txt`.
3. `build` orients from the progress log and git, builds one feature, commits, and leaves the repo clean.
4. `review` runs the real checks, grades feature by feature by execution, flips genuinely-passing features, and writes specific fixes for failures.
5. `loop` alternates build and review until done, the iteration cap is hit, or a feature exhausts its error budget.

## Install

This repo is the source of truth. Run the installer to make the skills available to Claude Code:

```bash
./install.sh          # symlink, so repo edits are live immediately (default)
./install.sh --copy   # copy instead, so changes apply only when you re-run it
```

Then in Claude Code the slash commands `/spec`, `/init`, `/build`, `/review` and `/loop` become available. If any name collides with an existing skill, rename the folder and the `name:` field in its SKILL.md to match (for example `loop-build`), and update `install.sh`.

Record meaningful prompt changes in `CHANGELOG.md`. Because skills are prompts, small wording changes can shift loop behaviour, so the history is worth keeping.

## Workflow

```
/spec    once, interactively, to produce the spec and feature list
/init    once, to scaffold the environment and verification harness
/loop    to build autonomously, bounded by the caps in loop-config.json
```

Use `/build` and `/review` by hand when you want to drive a single step yourself.

## The artefacts the loop reads and writes

- `specs/<name>.md` the human-readable spec
- `feature_list.json` the checkable feature list, status-tracked, never weakened to fake progress
- `loop-config.json` stack, run and verify commands, iteration cap, per-feature error budget
- `init.sh` install and run the app
- `verify.sh` lint, type-check, tests, and browser-driven end-to-end checks
- `claude-progress.txt` plus git history, so any fresh session can get its bearings fast

## Grounding

The design follows Anthropic engineering guidance on long-running agent harnesses (initializer plus coding agent, a JSON feature list, incremental progress, progress log and git, end-to-end testing), the Claude Agent SDK guidance on grounding self-correction in rules-based feedback, and the Building Effective Agents principles of explicit stopping conditions and keeping the system simple.
