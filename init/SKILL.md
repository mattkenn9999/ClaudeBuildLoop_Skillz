---
name: init
description: Scaffold the build environment for a loop-based software build, exactly once, before any feature work begins. Use this when the user says "/init", when a spec and feature_list.json exist but there is no init.sh or verify.sh yet, or right after /spec. This sets up the git repo, progress log, run script, and the verification harness that the rest of the loop depends on. Always run this before /build or /loop on a fresh project, because without it the build agent has no ground truth to test against and no way to recover state across sessions.
---

# init

This runs once at the start of a project. Its job is to lay the foundation that every later build and review session relies on: a way to run the app, a way to verify it by execution, a clean git history, and a progress log. After this runs, later agents starting with a blank context window can get their bearings quickly instead of re-deriving the project from scratch.

Do not implement product features in this step. Build only the scaffolding.

## Why this step matters

Real builds span several context windows, and each new session starts with no memory of the last one. The two classic failure modes are: trying to do everything at once and running out of context mid-feature, and a later session seeing some progress and wrongly declaring the job done. The artefacts you create here are what prevent both. The verification harness in particular is what turns "the model thinks it works" into "something ran it and it works".

## What to do

### 1. Read the inputs

Read `specs/<name>.md` and `feature_list.json`. Understand the stack and constraints. If the stack is not stated or implied clearly enough to write run and test commands, ask the user once, then proceed.

### 2. Write loop-config.json

This small file tells the loop how to run and how to stay in control. Tune the caps to the size of the project.

```json
{
  "project": "<name>",
  "stack": "node-react",
  "ui": true,
  "init_cmd": "./init.sh",
  "verify_cmd": "./verify.sh",
  "max_iterations": 30,
  "error_budget_per_feature": 3
}
```

`max_iterations` caps how many build/review cycles the loop may run before stopping for a human. `error_budget_per_feature` caps how many times the loop may attempt a single feature before giving up on it and surfacing it for help, rather than grinding indefinitely on a feature that keeps breaking other things.

### 3. Write init.sh

A script that installs dependencies and starts the development server or entry point, so no later session has to work out how to run the project. Make it idempotent and fast to run. Examples:

For a Node or React app:
```bash
#!/usr/bin/env bash
set -euo pipefail
npm install
npm run dev
```

For a Python service:
```bash
#!/usr/bin/env bash
set -euo pipefail
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python -m app
```

### 4. Write verify.sh (the most important artefact)

This is the ground-truth engine. It must run real checks and exit non-zero if anything fails, so the review step can trust its result rather than re-reading code. Include, in roughly this order and adapted to the stack:

- a linter
- a type-checker where the language has one (prefer typed languages and typed checks, they give the loop more layers of feedback)
- the test suite
- for anything with a user interface, an end-to-end smoke test driven through browser automation that exercises the app the way a real user would, not just a unit test or a curl

Example for a typed web app:
```bash
#!/usr/bin/env bash
set -euo pipefail
npm run lint
npm run typecheck
npm test
npm run test:e2e   # browser-driven, asserts real user flows
```

If the project has no tests yet, write verify.sh to run what exists now and leave a clear TODO marker for the categories still missing, so review knows coverage is partial rather than assuming green means done.

### 5. Initialise git and the progress log

- `git init` if not already a repo, then make an initial commit that records the scaffolding you added, with a clear message.
- Create `claude-progress.txt` with a short header: project name, the date, "scaffolding complete, no features implemented yet", and a note pointing the next agent to read `feature_list.json` and run `init.sh`.

### 6. Leave clean and hand off

Confirm the repo is in a clean, committed state. Tell the user the environment is ready and they can now run `/loop` to start building, or `/build` to do a single feature by hand. Do not start implementing features.
