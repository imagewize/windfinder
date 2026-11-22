---
name: wordpress-block-layout
description: "WordPress block layout and width rules for block themes: contentSize/wideSize, the per-block Wide/Full width setting (align), has-global-padding breakout mechanics, and how to verify rendered widths in the browser. Load when building or debugging page layouts, full-width sections, or when a block 'looks too narrow' in the editor or on the frontend."
user-invocable: true
license: MIT
metadata:
  version: "1.0.0"
  source: "imagewize/windfinder (authored 2026-11-22, from the Nynaeve/imagewize.com layout debugging session)"
---

# WordPress Block Layout & Width

Core mechanics of the block layout system (WP 6.6+), so width bugs get diagnosed instead of patched around.

## The three width levels

Set once per theme in `theme.json`:

```json
"settings": { "layout": { "contentSize": "52rem", "wideSize": "64rem" } }
```

- Default blocks render at **contentSize**, centered.
- `alignwide` blocks render at **wideSize**, still inside the root padding.
- `alignfull` blocks break out to the **viewport width**.

## The per-block width settings (where users look first)

- Block toolbar → **Width** (Default / Wide / Full) sets the `align` attribute. It only switches between the three levels above — it cannot set an arbitrary width.
- A **group** block's sidebar → Layout shows **Content width** / **Wide width** fields. These write `layout.contentSize` / `layout.wideSize` overrides onto that one block. That is a *fixed width* — fine for a one-off hero, wrong as a habit; change `theme.json` instead when a whole site feels narrow.

## Render mechanics (root-padding aware)

With `useRootPaddingAwareAlignments: true`, horizontal page padding comes from core: the theme's content wrapper carries `has-global-padding`, and `--wp--style--root--padding-left/right` apply there. Core then:

- caps constrained children at `contentSize` (`wideSize` for `.alignwide`),
- gives `.alignfull` **negative margins equal to the root padding** so it escapes to the viewport edge.

Crucially, that breakout only applies to `.alignfull` elements that are **direct children of the `has-global-padding` container**. An `alignfull` block nested inside a `wp:group` stays at its parent's width (nested constrained groups get their padding zeroed, so there is nothing to break out of).

Rules for custom full-width section blocks:

- Declare `"supports": { "align": ["wide", "full"] }` and default `"align": "full"` plus a zero-margin style default in `block.json` (WP injects `margin-block-start: 24px` on constrained children otherwise).
- Never set `width: 100%` on the block root — it defeats core's negative margins. Pad the **inner** wrapper under `.alignfull` with `var(--wp--style--root--padding-left/right)` and cap it at `var(--wp--style--global--wide-size)`.

## Diagnosing "too narrow" / "not full width"

1. Inspect the stored structure, not just the render: `wp eval 'foreach (parse_blocks(get_post(ID)->post_content) as $b) { echo $b["blockName"] . " align=" . json_encode($b["attrs"]["align"] ?? null) . PHP_EOL; }' --path=web/wp` — a wrapping `core/group` around a section block is the classic cause of a band that won't go full-bleed. Re-import the current draft before touching widths.
2. Measure the rendered page: in the browser, check each block's `getBoundingClientRect().width` and computed `margin-left`. A working full-bleed block shows `margin-left: -<root-padding>px` and viewport width; a broken one shows `0px` and the parent width.
3. Check for horizontal overflow at 390px and 1440px: `document.documentElement.scrollWidth === document.documentElement.clientWidth` at both. `overflow-x: clip` on `html, body` hides the symptom, not the cause.

## Guardrails

- Don't put `alignwide`/`alignfull` on core blocks in regular page content unless the theme's CSS is built for it — on constrained pages they can touch the screen edge on mobile.
- Don't hand-edit `contentSize` per block to "fix" spacing; use theme.json, spacers, or group padding.
