---
name: spec
description: Turn a software idea into a buildable spec and a structured, checkable feature list before any code is written. Use this whenever the user wants to start a new build, says "/spec", describes a feature or app they want, or asks to plan, scope, or define requirements for something to be built. Always use this at the very start of a loop-based build, even if the user is keen to jump straight to coding, because the rest of the loop depends on the artefacts this produces.
---

# spec

This is the first step of a self-correcting build loop. Its job is to understand what the user wants well enough that a build agent can work from the result without guessing, and to produce a feature list concrete enough that a review agent can verify each item by running it. Do not write any product code in this step.

## Why this step matters

A loop can only climb towards a target if the target is precise and checkable. Vague goals produce loops with no natural stopping point. The single most valuable thing you produce here is not the prose, it is `feature_list.json`: a list of end-to-end, user-observable behaviours that something can later run and confirm. Get that right and the rest of the loop has ground truth to grade against.

## What to do

### 1. Interview, one question at a time

Ask focused questions, one at a time, until you genuinely understand:

- the objective: what this is for and who uses it
- the must-have requirements, stated as things a user can do
- the constraints: stack, dependencies, performance, security, anything off limits
- explicit non-goals: what you should not build
- what "done" looks like, concretely enough to check

Do not move on while important things are still ambiguous. Do not start building. If the user resists the interview, push gently once on the highest-value unknown, then proceed with sensible assumptions recorded in the spec.

### 2. Write the prose spec

Save to `specs/<name>.md`. Include, in this order:

- Objective
- Requirements (numbered)
- Edge cases to handle
- Non-goals (what is deliberately out of scope)
- Definition of done (a checklist someone could verify against)
- Assumptions made (anything you inferred rather than confirmed)

### 3. Write the feature list

Save to `feature_list.json`. This is the spine of the whole loop. Turn each requirement into one or more end-to-end features. A good feature is observable from the outside (a user does X and sees Y), not an internal detail ("add a helper function"). Steps should read like a test someone could run.

Use exactly this structure:

```json
{
  "project": "<name>",
  "spec": "specs/<name>.md",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "description": "A user can create a new record and see it appear in the list",
      "steps": [
        "Open the app",
        "Click 'New'",
        "Enter a title and save",
        "Verify the record appears in the list"
      ],
      "priority": 1,
      "passes": false,
      "attempts": 0,
      "last_result": ""
    }
  ]
}
```

Rules for the feature list:

- Every feature starts with `"passes": false` and `"attempts": 0`. These are how the loop tracks progress and spends its error budget. Nothing is "done" until something runs it and confirms it.
- `priority` is an integer, 1 is highest. Order features so that foundational behaviour is built before behaviour that depends on it.
- Use JSON, not Markdown, for this file. The build and review agents are far less likely to quietly overwrite a JSON file, and this file must survive intact across many sessions.
- Be comprehensive. Under-listing here causes the loop to declare victory early. It is normal for a real app to have dozens of features. Prefer many small, checkable features over a few vague large ones.

### 4. Three checks that keep features verifiable

A feature that is end-to-end but not actually checkable in practice is where the loop wastes its error budget. Before finalising the list, apply these three checks. Each prevents a specific, recurring kind of thrash.

- **Pin the data in the feature that produces it.** If one feature's pass condition depends on specific input data (a duplicate or tie-inducing pair, a known near-miss, a value that lands in a particular range, a record with a specific shape), the feature that *creates* that data must specify it concretely, not just describe the data set in the abstract. Otherwise the build invents arbitrary data and the dependent feature becomes hard or impossible to satisfy. Name the exact entries and the probe that exercises them.

- **Verify process-boundary contracts by running the process.** When a behaviour is observable only at the boundary (a process exit code, what lands on stdout versus stderr, a file written to disk, an HTTP status), the feature must be checked by running the real thing end to end, not by calling an inner function and inspecting its return value. State this in the steps ("run the CLI as a subprocess and assert the exit code", "drive the UI and observe what renders"). A green test that never crossed the boundary does not verify the contract.

- **Keep inner functions injectable when the product contract is fixed.** Sometimes the product deliberately locks something down (a path that is not user-configurable, a fixed endpoint, a constant). The error and edge-case features still need to exercise the locked thing with bad or alternative values. Resolve the tension by keeping the *inner function* parameterised (defaulting to the fixed value) so tests can inject alternatives, while the *outer interface* stays locked. Note this in the spec so the build does not hard-code the value inline and leave the edge cases untestable.

## Hand-off

When the spec and feature list are written, stop and tell the user to run `/init` next to scaffold the build environment. Do not run `/init` yourself and do not start building.
