# Theme docs: AGENTS.md, README.md, CHANGELOG.md

Every theme a demo creates gets three docs on day one, before the first pattern:

- An **Elayne child theme** — a standalone repo like `~/code/elayne-<vertical>` or a theme directory inside the demo
  repo (`theme-<vertical>/`) — is one case.
- A **standalone theme** (no parent, for example the Aviendha fork used in Mode B) gets the same three files.
  Nothing below is child-theme-specific; a fork needs them too.

Write all three while setting the theme up, not after a failed first run. A session that starts without an `AGENTS.md`
re-derives paths, tooling rules and spacing budgets by trial and error, which is where hours get lost.

## README.md (about a screen)

- What the theme is: standalone or child (and of which parent from wp.org), the vertical, the client or demo it
  belongs to, link to the demo repo's brief.
- Setup: required parent + plugin slugs, how the theme is installed on the local site (symlink target, `wp --path`).
- A palette/typography summary that *points at* `styles/<variation>.json` — values live there, never copied here.
- Status and open questions (what the client still has to check before go-live).

## AGENTS.md

The agent-facing contract for anyone working in the theme. Keep it a few screens:

- **Paths, spelled exactly**: the theme directory name (state the spelling once, with the common typo called out),
  the demo repo root, the local site root and URL, the parent-theme source path.
- **Pattern conventions**: docblock fields, slug policy (child overriding a parent slug vs a new slug), the text
  domain, image handling (`get_stylesheet_directory_uri()` or `get_template_directory_uri()`, no `uploads/` URLs),
  trailing newlines.
- **Section rhythm budget**: copy the numbers from the parent theme's `AGENTS.md` (or from this skill's step 4) so a
  session that never loads the skill still sees them.
- **Validation commands that work for this theme**: sentinel invocation with the `.env` pattern, `php -l`, the screenshot
  script — commands a session can copy verbatim.
- **Session guardrails learned in this repo**: blocked command shapes and their allowed replacements, screenshot
  discipline (widths, slicing), what routes through `run_typescript`/connectors instead of shell.

Credentials never appear here (`.env` only). Real client hostnames or mailboxes stay out of any file that might be
committed publicly; use placeholder names in a public theme.

Models for structure: the demo repos' `AGENTS.md` files that were written as a post-mortem after spacing-heavy first
builds — write this file on day one so the post-mortem is not needed.

## CHANGELOG.md

- `## [Unreleased]` at the top, sections `Added` / `Changed` / `Fixed` per entry; one line per change, present tense.
- Released versions get `## [x.y.z] — YYYY-MM-DD`. Bump the version in `style.css` in the same commit that releases it.
- Every pattern, variation or style change lands with a line here, in the same session that makes the change — never
  batched later from memory.
