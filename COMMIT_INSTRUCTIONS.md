# Git Commit Instructions

## Core principles

Commit work in small, atomic, incremental steps. Each commit must represent
one logical change — something that can be reviewed, reverted, or
cherry-picked independently without breaking the codebase.

The project must build and run correctly when checked out at **any** commit
you create. Never leave the tree in a broken state between commits.

When a task contains separable concerns — code, tests, UI, documentation —
prefer a sequence of small commits over one large commit. Split along those
boundaries naturally.

---

## Before every commit

1. **Run the tests.** Do not commit if any test that was passing before your
   change is now failing. Fix the regression first, then commit.
2. **Scan the diff for secrets.** Never commit API keys, passwords, tokens,
   private keys, or any credential — even temporarily. If one is found,
   remove it and rotate it before proceeding.
3. **Review `git diff --staged`.** Confirm staged changes belong to one
   logical unit of work. If they span multiple concerns, split them into
   separate commits.

---

## Commit granularity

- **Atomic:** do not mix changes with different purposes in one commit.
  One coherent reason to change the code per commit: add a feature, fix
  a bug, refactor a module, update a dependency, etc.
- **Incremental:** commit as soon as a self-contained unit is complete and
  tests pass. Do not accumulate work and dump it in one large commit.
- **Separable changes go in separate commits:** production code, tests,
  documentation, and build/tooling changes that address different concerns
  should each get their own commit even if they were written together.

---

## Commit message format

Follow the **Conventional Commits** specification. Every commit message
must have this structure:

```
<type>(<scope>): <subject>

<body>

<trailers>
```

### Type

| Type       | When to use                                             |
|------------|---------------------------------------------------------|
| `feat`     | New feature or user-visible capability                  |
| `fix`      | Bug fix                                                 |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test`     | Adding or correcting tests                              |
| `docs`     | Documentation only                                      |
| `chore`    | Build system, tooling, dependency updates               |
| `perf`     | Performance improvement                                 |
| `ci`       | CI/CD configuration changes                             |

### Scope

Optional. Name of the module, subsystem, or file most affected.
Examples: `feat(parser):`, `fix(auth):`, `chore(deps):`.

### Subject line

- Imperative mood: "add", "fix", "remove" — not "added", "fixes", "removed".
- 72 characters max. No period at the end.
- Describe the **user-visible or engineering outcome**, not a vague action.

Good: `feat(burst-detector): add per-channel SNR threshold`
Bad:  `feat(burst-detector): added SNR stuff and also fixed the loop`

### Body

- Required for every non-trivial commit. Separate from subject with one
  blank line.
- Explain **why** the change is needed. Note any non-trivial technical
  decisions or tradeoffs made.
- Do not restate what the diff already shows — explain the reasoning.
- Wrap lines at **70 characters**.
- 3–8 lines is usually sufficient.

### Trailers

Trailers go after the body, separated by a blank line. Required and optional
trailers are listed below.

**Always present:**

```
Signed-off-by: Oleksandr Suvorov <cryosay@gmail.com>
```

**For `fix` commits that correct a regression:** use `git blame` to find
the commit that introduced the bug, then add:

```
Fixes: <full-commit-hash> ("<subject of that commit>")
```

**When an issue or ticket exists:**

```
Closes #42
Refs #17
Part of #99
```

**For breaking changes:**

```
BREAKING CHANGE: <what breaks and how to migrate>
```

---

## Full examples

### Feature commit

```
feat(fhss-jammer): add per-burst OFDM power normalisation

Without normalisation the output amplitude varied by up to 6 dB
across FHSS channels due to differing FFT bin counts. This caused
inconsistent jamming effectiveness at channel edges.

Normalise each burst's IQ samples to unit RMS before upconversion
so that transmitted power is uniform regardless of channel index.

Closes #34
Signed-off-by: Oleksandr Suvorov <cryosay@gmail.com>
```

### Fix commit with regression trailer

```
fix(burst-detector): clamp negative SNR values before log10 call

A negative power estimate passed to log10() produced NaN, silently
dropping the burst from the detection pipeline. The root cause was
an underflow when the noise floor estimate exceeded the signal
window integral on very short bursts.

Clamp the ratio to a minimum of 1e-12 before the log call.

Fixes: a3f812c9b1e4 ("feat(burst-detector): add per-channel SNR threshold")
Signed-off-by: Oleksandr Suvorov <cryosay@gmail.com>
```

---

## What not to do

- Do not write `fix: fix bug` or `chore: update stuff` — subjects must be
  specific and outcome-oriented.
- Do not commit commented-out code, debug prints, or `TODO` stubs added
  during this session unless they are intentional and explained in the body.
- Do not use `git commit -m` with a long message; open the editor so the
  body and trailers are formatted correctly.
- Do not force-push to shared branches after a commit is pushed.
- Do not omit `Signed-off-by` — it is required on every commit.
