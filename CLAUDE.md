# Development Practices

<!-- Versioned copy of ../DEVELOPMENT-PRACTICES.md (workspace root, canonical — auto-imported by the workspace CLAUDE.md). If you edit one, sync the other in the same change. -->

> **Reusable block.** Copy this file as-is into any project (or link/import it from the project's `CLAUDE.md` / `AGENTS.md`). It describes **how work gets done**, not any project's architecture. Concrete commands are shown for one stack (TypeScript/NestJS/Jest/ESLint/git) — swap them for the target project's equivalents; the practices themselves never change.
>
> Written to be followed **literally**, by any agent or developer regardless of skill: every practice has a trigger (when it applies) and a done-check (how you know you applied it). Three rules about this file itself:
>
> - If a practice references an artifact the project doesn't have yet (gotcha table, change-type checklist, tracking doc), **create it the first time it's needed** — never skip a practice because its file is missing.
> - When tempted to skip a practice "because this change is small": that is exactly the change these practices exist for. Small changes get less attention, which is why they break things.
> - If a gate cannot run (no test runner, no lint config, no environment), say so explicitly to the user instead of silently skipping it.

## When each practice applies

| Moment | Practice to apply |
|---|---|
| Before editing anything | **Scope discipline** · consult the **Checklist by change type** and the **Gotcha table** |
| When fixing any bug | **Root cause before fix** |
| While writing code and tests | **Tests follow behavior** |
| Before every commit | **Pre-commit gates** · **Shared-working-tree discipline** |
| Before saying "done" / "fixed" / "passing" | **Verification before claiming done** |
| At the close of a work unit | **Adversarial review** · **Documentation is part of the task** |
| After any bug that took >15 min to understand | add a row to the **Gotcha table** |
| Work spanning sessions or agents | **Handoff for long-running work** |

## Scope discipline

- Touch only what the task requires. No drive-by refactors, no reformatting files you aren't otherwise editing, no "while I'm here" fixes — collect those as notes for the user instead.
- Produce the smallest diff that accomplishes the task **correctly**. A rename or signature change legitimately touches many files; a one-line fix that also reorders imports in five files does not.

**Done when:** every hunk in `git diff` traces back to the task's requirement.

## Root cause before fix

- **Reproduce first.** The best reproduction is a failing test; second best is a command you can re-run on demand.
- **Explain the mechanism before changing code.** If you cannot state *why* it fails, you are not fixing the bug — you are perturbing the code until the symptom moves.
- **One fix at a time.** Bundling several "possible fixes" hides which one worked and what each one broke.
- After the fix, **re-run the same reproduction** and watch it pass. Keep it as a regression test.

**Done when:** the original reproduction passes, you can state the failure mechanism in one sentence, and the reproduction is committed as a regression test.

## Tests follow behavior — never the other way around

- If behavior changed, update the tests to assert the **new** behavior. Never weaken an assertion, broaden a matcher, delete a test, or add a mock **just to turn a red test green** — a red test after your edit is information: first decide whether the test is stale or your code is wrong.
- Every new logic branch, edge case, or handled error path gets a test. Happy path only = not covered.
- Changed a constructor or function signature? Grep every caller **and every test that constructs the class** — positional mocks break silently.

```bash
grep -rn "new MyService(" src/
```

**Done when:** each changed behavior has a test asserting the new behavior, and every test you edited can be explained as "the spec changed" — never as "it wouldn't pass".

## Pre-commit gates

Three checks, in this order, before **every** commit — replace the placeholders, keep the order:

```bash
# 1. Clean type/compile check. Wipe incremental caches first: a stale cache
#    can report "clean" over a real error.
rm -f tsconfig.build.tsbuildinfo && npx tsc --noEmit -p tsconfig.build.json

# 2. Tests for the touched surface PLUS its direct consumers — regression
#    coverage on adjacent modules is cheap insurance.
npx jest <paths of touched modules> <paths of adjacent modules>

# 3. Lint ONLY the touched files — never repo-wide, never the project's
#    global formatter command (it pollutes other people's diffs).
npx eslint --fix <touched files>
```

**Done when:** all three exit 0 **and you read the output** — watch for "0 tests found", skipped suites, and new warnings; an exit code alone hides all three.

## Verification before claiming done

Evidence before assertions, always:

- Never say "done", "fixed", "passing", or "deployed" without having **run the command that proves it in this session and read its output**.
- Can't run the proof (missing env, credentials, hardware)? Say exactly that: "implemented but NOT verified — needs X".
- Report failures faithfully: paste the failing output, don't summarize it into something softer.

**Done when:** every claim in your report is backed by command output produced in this session — each "it works" has the command and its output behind it.

## Checklist by change type

Keep a living table "change type → required checks" in the project's agent instructions (`CLAUDE.md` or a doc linked from it). Consult it **before** starting a change of that type; add rows after every bug hunt — each row exists because a real bug made it necessary.

Starter rows (generic — replace and extend with the project's own):

| Change type | Check before shipping |
|---|---|
| New DB table / migration | Delete behavior of every FK decided (cascade? set null? orphan?); migration present for **all** environments the project maintains; long-running index builds use the non-blocking strategy |
| New endpoint / route | Auth check effective **on the handler** (verify how the framework resolves guards — a class-level guard may be dead); input validated; IDs/fields crossing the wire follow the project's encoding policy; route actually mounted — hit it once |
| New wire contract / event | Every consumer updated in the same change, or the gap explicitly tracked; consumer-facing doc updated |
| New background job / sweep | Single-winner claim under concurrency (conditional update; `<=` not `=` on timestamps); every fire-and-forget promise logs its rejections; crash after claim ⇒ retried, not lost |
| Change to a shared core component | Grep **all** call sites, not just the one you came from; run the consumers' test suites too |
| New env var / config key | Documented in the project's env table immediately; deployment values/templates updated or flagged as pending |

**Done when:** you can point at the row you checked before starting — or at the row you just added because it was missing.

## Shared-working-tree discipline

When other people or agents touch the same checkout in parallel:

1. `git status --porcelain | wc -l` **before starting** — record the baseline count of files that are not yours.
2. Stage explicit paths only. Never `git add -A`, `git add .`, or wildcards.
3. Check whether commit hooks sweep the whole tree (e.g. repo-wide lint-staged): if they do, scope or bypass them — otherwise your commit silently captures other people's files.
4. `git status --porcelain | wc -l` **after committing** — compare with the baseline.

**Done when:** the post-commit count equals the baseline plus only the files you deliberately left uncommitted. Anything else means you staged someone else's files or a hook rewrote the tree: stop and repair before doing anything else.

## Adversarial review at the close of a work unit

**Trigger:** the work unit spans ≥3 source files, or introduces a new module / wire contract / background process / security boundary, or took more than one session. When in doubt, run it.

1. **Find** — review the full diff plus the adjacent files it touches, once per lens: correctness & races · security/authz/tenant isolation · wire contracts & data loss · cost/billing (when applicable) · test gaps. With subagent capability, run the lenses as parallel finders; without it, run them as **separate sequential passes** — one lens at a time. A single mixed pass finds the shallow bugs of every lens and the deep bugs of none.
2. **Dedup** findings by (file, nature of defect).
3. **Refute** — for each finding, actively try to prove it **false** against the real code (independent verifiers if you can spawn them; otherwise re-derive it from scratch by reading the actual code paths, not your memory of them). A finding survives only if the refutation attempt fails.
4. **Fix every confirmed finding and add a regression test for each.** Record the score: confirmed / distinct / critical.

Skip step 3 and roughly half the findings of a single pass turn out to be false positives — the refutation step, not the search, is what keeps the signal clean.

**Done when:** a full find-pass over the final (post-fix) code yields zero new confirmed findings.

## Documentation is part of the task

- Tracking/design docs update in the **same commit round** as the code — "later" means never.
- A contract change (API, event, wire format) updates the consumer-facing doc in the same change.
- A new env var or config key gets its table row immediately, even before the infrastructure wiring exists.
- Deferred scope is **declared** in the tracking doc, never silently dropped.

**Done when:** the commit round contains the doc updates alongside the code — not a TODO promising them later.

## Gotcha table (lessons already paid for)

Keep a short "gotcha → rule" table for surprising behavior discovered in the field: race conditions, library quirks, caches that lie, framework footguns.

- Add a row whenever a bug took more than ~15 minutes to understand.
- Consult it before working in an area it covers.
- One line per gotcha — the trap, then the rule that avoids it:

| Gotcha | Rule |
|---|---|
| Incremental compile cache reports a stale "clean" | Wipe the cache file before any check that must be trusted |
| Timestamp equality in claim queries starves under driver precision round-trips | Always `<= now()`, never `=` |

**Done when:** any bug that cost you more than ~15 minutes this session has its row before the session ends.

## Handoff for long-running or multi-agent work

Work spanning multiple sessions or agents keeps **two documents**:

- a **living tracking doc** — phase/block status, decisions taken, lessons learned, ops notes; updated at every milestone, not at the end;
- a **handoff doc** — what remains (in order), the architecture in ~10 lines, a verification guide (the practices above instantiated with the project's real commands), and the gotcha table.

Whoever picks up the work reads both **before** writing code — and so do you, at the start of every session on that work.

**Done when:** someone with no prior context could resume the work from the two documents alone, as of your last commit.
