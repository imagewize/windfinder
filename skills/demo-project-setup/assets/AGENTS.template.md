# AGENTS.md — {{NAME}} demo ({{PROJECT_FOLDER_NAME}})

Project: {{NAME}} — {{WHAT_FOR}}. This folder is the demo/project repo. The brief lives in `README.md`,
the stage prompts in `PROMPTS.md`, image credits in `images/CREDITS.md`. Read this file before any
command; it is the contract for every session in this folder.

## Paths — verify before you run

- Repo root: `{{PROJECT_DIR}}`.
- Local site: **https://{{SITE}}.test** (Laravel Valet, login `admin` / `admin`; `wp --path="{{SITE_DIR_ABS}}"` —
  never `~` after `=`).
- Theme directory: `theme-{{THEME_SLUG}}/` ({{THEME_MODE}}), symlinked to
  `wp-content/themes/{{THEME_SLUG}}` in the site, so edits here are live immediately.
- Check a failing path with `ls` before re-running, and do not narrate the typo to the user.

## Section rhythm budget

Spacing is the most-expensive class of review fix, so it is budgeted up front and verified by
measurement, not by eye:

- Section padding top/bottom: default one tier up from the in-section spacing; dense sections one
  tier less (HTML prototypes: 32–48px at 1440; block themes: the theme scale's `large`).
- Hero and banner bands: at most 80px per side at 1440 (theme scale `x-large`).
- The two paddings meeting at a section boundary stay within **112px together at 1440 and 64px at
  390**: at most one side of a boundary may be `x-large`, never `xx-large`/`xxx-large` as section
  padding in new patterns.
- One padding layer per section: the outer wrapper pads, inner wrappers add no extra top/bottom
  padding; vertical flow uses one `blockGap`/gap value, not per-element margins.
- A spacing value you did not measure is "expected", not a fact: verify with
  `html-page-review/measure.mjs` before reporting a build done.

## Tooling guardrails

- One command per call, no `&&` chains, no shell variables, no `$(…)` and no `>` redirects: each of
  those stops the session for an approval. `echo ---` as a separator, never `echo ===`.
- Absolute paths written out in full in every command.
- Read/validate JSON with `jq`, never `php -r`, `python3 -c` or `node -e`.
- Credentials go in a `.env` file, never on a command line; never commit them.

## Review & commits

- After visual changes, re-check at 1440 and 390 and record findings in `REVIEW.md` (screenshots
  under `/tmp/…`). Numbered notes, one visible problem per note.
- Commits: short, Title-Case, atomic, attribution-free (no AI/tool footers).
- Every change to the theme gets a `CHANGELOG.md` line in the same session, under `[Unreleased]`.
