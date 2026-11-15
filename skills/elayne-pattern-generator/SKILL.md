---
name: elayne-pattern-generator
description: "Create, convert, port or audit block patterns for the Elayne FSE theme or an Elayne child theme (any vertical, including HTML prototypes from elayne-content), and re-shoot the theme's screenshot.png. Use for Elayne pattern, page composite, vertical, compliance or screenshot work."
user-invocable: true
allowed-tools:
  - read_file
  - write_file
  - bash
  - grep
metadata:
  version: "1.0.0"
  source: "github.com/imagewize/wp-vibe-toolbox skills/elayne-pattern-generator"
---

# Elayne pattern workflow

This skill is deliberately thin. Elayne changes often, so it never copies palette values, font sizes or full
rule lists. The theme repo is the source of truth; read it fresh every time. An older version of this skill
hardcoded fonts, colours and scales that drifted badly.

`SKILL_DIR` below is this folder, read from `skill_paths` in `~/.vibe/config.toml`
(for example `~/code/wp-vibe-toolbox/skills/elayne-pattern-generator`).

## 0. Read the source of truth first (always)

Before writing anything, with targeted reads (`grep` first, then `read_file` with offset and limit):

1. `theme.json` and the relevant `styles/*.json` in `~/code/elayne`: real colour slugs, font families, font-size
   and spacing scales, border-radius presets. Do not assume values from memory.
2. `AGENTS.md` (or `CLAUDE.md`) in `~/code/elayne`: the "Critical Pattern Rules" table, the Design System
   section and the **Colour contract** row. If a rule here disagrees with that file, the file wins.
3. Two or three sibling patterns in `patterns/` of the same vertical, for current header fields, `metadata.patternName`
   and image handling.

If these files cannot be read, say so and stop. Do not fall back to remembered values.

## 1. Choose the workflow

- **Pattern spec** (structured Slug/Title/Content text): read `SKILL_DIR/references/pattern-spec-format.md`, then scaffold per step 2.
- **HTML prototype to port** (`~/Documents/elayne-content/<vertical>/index.html`): step 3.
- **New pattern by description**: take the closest sibling pattern in the same vertical, then scaffold per step 2.
- **Fix or audit a pattern**: check it against the rules table and `references/block-json-rules.md`, list violations
  with `file:line`, fix, then validate per step 5.
- **Page composite** (`page-*.php`): a list of `<!-- wp:pattern {"slug":"elayne/..."} /-->` references and
  **nothing else**: no wrapper group, no PHP `include`, no spacer. The rules table says why. Sentinel always reports
  `content_mismatch` for these; that is a known limitation, not a bug.
- **New vertical**: a child theme (`~/code/elayne-<vertical>`, `elayne-legal` is the worked example), never new vertical
  patterns in the parent. Use the child's text domain and `get_stylesheet_directory_uri()` for vertical images.
- **Screenshot**: step 6.

## 2. Scaffold, never hand-write block JSON

Run from `~/code/elayne` with pt-cli:

- Structural sections: `composer layout:create -- --title="..." --slug="elayne/..." --layout=<full-width|two-column|three-column|sidebar-left|sidebar-right|hero-image-left|hero-image-right|landing-page> --category="elayne/..." --output-dir=patterns/`
- Template-based (hero-cover, feature-grid-3col, two-column-text-image, stats-bar-fullwidth, testimonials-grid,
  cta-fullwidth, header-standard, footer-standard, team-grid, pricing-comparison, woo-*):
  `composer pattern:create -- --template=<t> --title=... --slug=... --category=... --output-dir=patterns/ [--with-style --style-dir=assets/styles/block-styles/]`
- Complex or non-standard: `--shell-only`, build in the block editor, paste over the marker.

Before touching cover, columns, button or heading blocks, read the matching guards in
`vendor/imagewize/pt-cli/snippets/` (`valid-*.txt`, `responsive-grid-min-width.txt`). After scaffolding, change
content only; do not restructure the block JSON. Two accepted exceptions: match the prototype's proportions, and
strip inline spacing the scaffold over-emits.

## 3. Porting an HTML prototype

1. **Slug contract first**, before any PHP: map every CSS variable to a palette slug **from the colour contract**,
   every font size to a preset, every spacing value to a spacing slug, every radius to a radius preset, every icon or
   emoji to an SVG. Flag complex CSS (absolute badges, hover effects, gradient text) that needs a block-style CSS file.
2. Map each section to a scaffold, then customise.
3. Prototype rem values usually come out too large in the theme scale; expect H1, body and pill sizes to drop one step.
4. Grids of 3 or more columns are `wp:group` grids with `minimumColumnWidth`, not `wp:columns`.
5. **Images:** Unsplash, Pexels and Pixabay are for design review only. Shipped images must be CC0 or GPL-compatible,
   converted to WebP, under `patterns/images/<vertical>/`, referenced through `esc_url( get_template_directory_uri() )`,
   never hotlinked. Ask about portrait or landscape crops instead of guessing, and add credits to `readme.txt`.

## 4. Rules that cause the most fix cycles (check the exact wording in the rules table)

No `wp:html` in patterns. No HTML comments or whitespace between a `<div>` and its block comment. Outer `alignfull`
group is `layout:default` with margin `"0"` strings; the inner group is `constrained`. `backgroundColor`, `layout`,
`align`, `className` and `metadata` are root-level, never inside `style`. No spacer blocks, and no inline
`gap`/`margin`/spacing padding where a parent `blockGap` applies. Button font size through
`style.typography.fontSize` with a preset variable; button radius paired with width `0px`. No `&` or `--` in
block-comment JSON (use `var:preset|color|slug` and single-dash class names). **Colours only from the contract slugs**
(`primary`, `on-primary`, `accent`, `accent-light`, `main`, `main-accent`, `base`, and so on); no hex, no gradient slugs,
never `secondary` or `border-*` as a text colour. No emoji. Fictional emails only. All text through `esc_html_e`,
`esc_attr__` or `wp_kses_post( __() )` with the theme's text domain. Real UTF-8 characters, never `\uXXXX`, in PHP strings.

## 5. Validate (never claim a pattern passes until a validator has run)

- **Pass 0**, after a WordPress or WooCommerce upgrade: `./scripts/check-pattern-blocks.sh` from the Elayne repo root.
- **Pass 1** (Trellis VM; it reads the copy installed on the demo, so sync first): `wp pattern validate <file> --fix`.
- **Pass 2**: `composer check` or `pt-cli check patterns/<file>.php --theme=elayne`; also `composer check:colors`.
- **Pass 3**: `npm run validate:file -- patterns/<file>.php` (sentinel, real browser).
- **Pass 4**, when templates or parts changed: `pt-cli check:templates templates/ --theme=elayne`.
- Then a visual review. None of the passes catch oversized fonts or bad crops.

Sync a working copy to the demo with an explicit source, never from inside the demo site:
`SITE_ROOT=~/code/imagewize.com/demo/web/app wp-ops rsync-package-to-site theme elayne ~/code/elayne`.
Never edit the demo site's copy of the theme.

## 6. Re-shoot `screenshot.png`

WP.org wants a clean 1200x900 render of the theme's homepage: no version badge, no "released this week", no
availability pill, no cookie banner. Do it with the script, not by improvising:

```bash
# after syncing the working copy to the demo (step 5)
SKILL_DIR/scripts/screenshot.sh --pattern elayne/page-homepage --out ~/code/elayne/screenshot.png
```

It renders the pattern on a throwaway page, hides the cookie banner, fails if the page contains promo text
(`--forbid` overrides the regex) or a block error, takes the PNG with `html-page-review/measure.mjs`, checks the size
and deletes the page. Then **open the PNG and look at it** before committing; the script cannot judge a bad crop.
`--dry-run` prints the plan without touching the site. Do not browse the web, check WP.org stats or hunt for other
screenshot tooling: this script is the sanctioned path.

## 7. Output

Report in a few lines: the scaffold commands used, the files changed, the validators run with their result, and the
decisions that need the user (image crops, licences). No narration of the exploration.
