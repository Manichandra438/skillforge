---
name: guideline-review
description: Reviews the current repo against docs/ENGINEERING_GUIDELINES.md, writes a severity-ranked findings report, asks for approval, then fixes only what's approved.
trigger: /review-guidelines
---

# /review-guidelines — Guideline Compliance Reviewer

Audits the current project against its engineering guidelines doc, produces a single markdown report with every finding classified **Critical / Major / Minor**, asks the user which ones to fix, then applies only the approved fixes and updates the report with the outcome.

Never fixes anything without an explicit approval step. Never invents guidelines beyond what the guidelines doc says.

## Usage

```
/review-guidelines                        # run a full review, write report, ask for approval
/review-guidelines fix all                # apply every open finding in the latest report
/review-guidelines fix critical           # apply only Critical findings in the latest report
/review-guidelines fix C1,M3,N2           # apply specific finding IDs
/review-guidelines fix C1,M3 <report.md>  # apply specific IDs in a named report file
/review-guidelines list                   # list past reports + their status
```

---

## What You Must Do When Invoked

Parse the text after `/review-guidelines`. No subcommand → Step 0 (full review). `fix ...` → Step 2. `list` → Step 3.

---

## Step 0 — Full Review

### 0A — Locate the guidelines doc

Check, in order, for the first that exists:
1. `docs/ENGINEERING_GUIDELINES.md` (current project)
2. `ENGINEERING_GUIDELINES.md` (project root)
3. `~/.claude/ENGINEERING_GUIDELINES.md` (global fallback)

If none exist, stop and print:
```
No guidelines doc found. Looked for docs/ENGINEERING_GUIDELINES.md, ./ENGINEERING_GUIDELINES.md, ~/.claude/ENGINEERING_GUIDELINES.md.
Add one of these, or tell me the path, then re-run /review-guidelines.
```

### 0B — Scan the repo

Read the project tree. Include: source/code files, config/manifest files, docs, `README.md`, `CLAUDE.md`. Exclude: `node_modules/`, `.git/`, `__pycache__/`, `dist/`, `build/`, `vendor/`, lockfiles' contents (check they exist, don't parse them), `kb/`.

For a large repo, sample deliberately rather than reading every file: prioritize entry points, the most-changed files (`git log --name-only -50` if it's a git repo), config/manifest files, and anything already flagged in `kb/anti-patterns.md` if that file exists.

### 0C — Evaluate section by section

Go through every numbered section of the guidelines doc. For each section:
- If it doesn't apply to this repo's nature (e.g. a "Data & Persistence" section when the repo has no database) — mark it **N/A** in the report, don't force a finding.
- If it applies, check the repo against every rule in that section. A rule is a finding only if you can point to a concrete file/location that violates it — no vague "could be better" findings.

### 0D — Classify severity

Use these definitions (apply consistently; don't ask the user to define severity per finding):

- **Critical** — will cause data loss, a security exposure (secrets, injection, auth bypass), broken installs/build for all users, or silent incorrect behavior in a shipped path.
- **Major** — violates architecture/design rules, missing tests or error handling around logic that matters, meaningful portability/maintainability problem, breaking-change risk with no migration path.
- **Minor** — naming, style, missing/stale docs, small readability or consistency issues, non-blocking nits.

### 0E — Write the report

Ensure `kb/reports/` exists (create `kb/` and `kb/reports/` if missing — don't run full `/kb init`, that's a separate skill's job and out of scope here).

Write `kb/reports/{YYYY-MM-DD}-engineering-review.md`. If a report for today already exists, append `-2`, `-3`, etc. — never overwrite a same-day report silently.

```markdown
---
date: {today}
type: engineering-guidelines-review
guidelines-source: {path used in 0A}
status: pending-approval
total: {N}
critical: {N}
major: {N}
minor: {N}
---

# Engineering Guidelines Review — {today}

## Summary

| Severity | Count |
|----------|-------|
| Critical | {N}   |
| Major    | {N}   |
| Minor    | {N}   |
| **Total open** | **{N}** |

Sections reviewed: {list}
Sections marked N/A: {list, with one-line reason each}

## Critical

### [C1] {short issue name}
- **Location:** `{file}:{line}`
- **Guideline:** {§ section name from guidelines doc}
- **Issue:** {what's wrong, concretely}
- **Fix:** {what change would resolve it}
- **Status:** open

{repeat C2, C3, ... — omit this whole section if zero Critical findings}

## Major

### [M1] {short issue name}
- **Location:** `{file}:{line}`
- **Guideline:** {§ section name}
- **Issue:** {description}
- **Fix:** {proposed change}
- **Status:** open

{repeat M2, M3, ... — omit section if zero}

## Minor

### [N1] {short issue name}
- **Location:** `{file}:{line}`
- **Guideline:** {§ section name}
- **Issue:** {description}
- **Fix:** {proposed change}
- **Status:** open

{repeat N2, N3, ... — omit section if zero}

## Resolution Log

{empty until fixes are applied (Step 1 or Step 2) — populated with what got fixed, skipped, or deferred, and when}
```

### 0F — Report in chat + ask for approval

Do not just say "see the file." Print in the chat response itself:
- The summary table (Critical/Major/Minor counts, total)
- Every finding as one line: `{ID} — {short issue name} ({file}:{line})`
- The path to the written report file

Then explicitly ask:
```
Which should I fix? Reply with "fix all", "fix critical" (or major/minor), specific IDs
like "C1, M3", or "skip all". I'll only touch what you approve.
```

Stop the turn here. Do not fix anything yet, even if the fix looks obvious or trivial.

---

## Step 1 — Handling the User's Approval Reply

This happens in the same conversation, as a normal reply to Step 0F's question — not necessarily as a `/review-guidelines` invocation. When the user answers that question (e.g. "fix critical and major", "just C1 and N2", "skip the minor ones"):

1. Map their reply to specific finding IDs from the most recently written report.
2. For each approved ID: make the fix, following every relevant rule in the guidelines doc (e.g. a security fix must still avoid introducing new vulnerabilities; a test-coverage fix must follow [testing conventions in the guidelines]).
3. After each fix, verify it (run the test suite / linter / build if the project has one) before marking it resolved.
4. Update the report file: for every ID the user addressed (approved or explicitly declined), change its `**Status:**` line and add a `## Resolution Log` entry:
   ```
   - **{ID}** — {fixed | skipped (user declined) | skipped (deferred)} — {today} — {one-line note, e.g. commit/diff summary or reason skipped}
   ```
5. Update the frontmatter `status:` to `resolved` (all addressed), `partially-resolved` (some left open), or `declined` (user skipped everything).
6. Print a summary: what got fixed, what got skipped and why, what's still open.

Never fix an ID the user didn't approve, even if it's in the same severity tier as one they did approve.

---

## Step 2 — `/review-guidelines fix ...` (standalone invocation)

For when the user runs this later, in a fresh trigger, instead of just replying inline:

1. Determine target report: if a filename is given, use it; otherwise use the most recent file in `kb/reports/` by date in the filename.
2. If that report's `status` is already `resolved`, print `Report already fully resolved.` and stop.
3. Parse the ID/severity/`all` argument the same way as Step 1.
4. Run the same fix → verify → update-report → summarize flow as Step 1.

---

## Step 3 — `/review-guidelines list`

1. List every file in `kb/reports/`, sorted newest first.
2. For each, read frontmatter and print: `{filename} — {status} — {total} findings ({critical}C/{major}M/{minor}N)`.
3. If `kb/reports/` doesn't exist yet, print `No reviews run yet. Use /review-guidelines to start one.`

---

## Rules

- Never fix anything the user hasn't approved, even a one-character typo fix spotted in passing — log it as a finding instead, or mention it separately.
- Never invent findings not traceable to a specific rule in the guidelines doc. If something looks wrong but isn't covered by the doc, mention it as a side note outside the report, not as a numbered finding.
- Keep finding descriptions concrete: cite the actual file/line and the actual guideline section, not a paraphrase of the whole guidelines doc.
- A repo with zero findings still gets a report (all sections either passing or N/A) — don't skip writing one just because the repo is clean.
- Do not touch unrelated files while fixing an approved finding — same scope discipline as the guidelines doc's own "Guidelines for AI Assistants" section.
- Do not modify `kb/anti-patterns.md`, `kb/decisions/`, or any other kb skill file as a side effect — this skill only reads guidelines and writes to `kb/reports/`.
