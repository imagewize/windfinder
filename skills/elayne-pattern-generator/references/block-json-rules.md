# Elayne Block JSON Rules — Authoritative Reference

Every rule in this document is non-negotiable. A pattern that violates any rule
will fail the compliance checker and must be fixed before committing.

## PHP File Header

Every pattern file starts with this exact structure:

```php
<?php
/**
 * Title: Human-Readable Pattern Name
 * Slug: elayne/vertical-pattern-name
 * Description: One-line description of what this pattern provides
 * Categories: elayne/vertical-name, elayne/section-type
 * Keywords: keyword1, keyword2, keyword3
 * Viewport Width: 1200
 * Block Types: core/cover (or core/group, core/columns, etc.)
 */
?>
```

All fields are required. Slug format: `elayne/` prefix + kebab-case name.

## Translation Wrappers

All visible text must be wrapped for translation:

- **Plain text** (no HTML tags inside): `esc_html_e( 'Your text here', 'elayne' );`
- **Text with HTML** (`<em>`, `<mark>`, `<br>`, `<strong>`, etc.):
  `<?php echo wp_kses_post( __( 'Text with <em>markup</em>', 'elayne' ) ); ?>`
- **Attribute values** that are translatable: `esc_html__( 'Text', 'elayne' )`

Never use raw text strings outside a translation function in a pattern file.

## Font Sizes

Use preset slugs only. Never hardcode px, rem, em, or any other unit.

| Preset slug | Approximate rendered size |
|---|---|
| `xx-small` | ~0.65rem |
| `x-small` | ~0.75rem |
| `small` | ~0.875rem |
| `base` | ~1rem |
| `medium` | ~1.125rem |
| `large` | ~1.5rem |
| `x-large` | ~2rem |
| `xx-large` | ~2.75rem |

In block JSON, font size is set with the `fontSize` attribute at root level
of the block comment for most blocks:

```
<!-- wp:paragraph {"fontSize":"base"} -->
```

**Exception — buttons:** Button blocks use `style.typography.fontSize` with the
full preset variable path, not root-level `fontSize`:

```
<!-- wp:button {"style":{"typography":{"fontSize":"var:preset|font-size|base"}}} -->
```

## Spacing

Use preset spacing slugs. Never hardcode pixel or rem values for padding, margin,
or blockGap.

**Available slugs:** `2-x-small`, `x-small`, `small`, `medium`, `large`,
`x-large`, `xx-large`, `xxx-large`

**Important:** There is no `xx-small` slug. The smallest slug is `2-x-small`.

In block JSON, spacing uses the `var:preset|spacing|slug` format:

```json
"style": {
  "spacing": {
    "padding": {
      "top": "var:preset|spacing|large",
      "bottom": "var:preset|spacing|large",
      "left": "var:preset|spacing|medium",
      "right": "var:preset|spacing|medium"
    },
    "blockGap": "var:preset|spacing|medium",
    "margin": {
      "top": "0",
      "bottom": "0"
    }
  }
}
```

In the rendered HTML, these become CSS custom properties:
`var(--wp--preset--spacing--large)`

## Colors

Use theme color slugs only. Never hardcode hex values.

**Available color slugs:**
- `primary` — dark navy/charcoal
- `primary-accent` — teal/cyan accent
- `primary-alt` — off-white/cream
- `primary-dark` — deep dark
- `main` — body text color
- `main-accent` — lighter body accent
- `base` — base text color
- `secondary` — secondary text/bg
- `tertiary` — tertiary text/bg

Colors are set in block JSON via `textColor`, `backgroundColor`, or
`overlayColor` attributes at root level:

```
<!-- wp:group {"backgroundColor":"primary","textColor":"primary-alt"} -->
```

Or via `style.color` for gradient and custom color needs.

## Border Radius

Use preset slugs: `sm`, `md`, `lg`, `pill`.
In block JSON: `"var:preset|border-radius|sm"`
In rendered HTML: `var(--wp--preset--border-radius--sm)`

Never hardcode pixel values for border-radius.

## Layout Structure for Full-Width Patterns

Full-width patterns follow a strict nesting structure:

```
Outer Group (align:full, layout:default, margin:0/0)
  └── Inner Group (layout:constrained)
        └── Content blocks
```

**Outer group attributes:**
```json
{
  "align": "full",
  "layout": {"type": "default"},
  "style": {
    "spacing": {
      "margin": {"top": "0", "bottom": "0"},
      "padding": { ... }
    }
  }
}
```

Key details:
- `layout.type` on outer group is `"default"`, not `"constrained"`
- Margin values are strings with no units: `"0"`, not `"0px"`
- The outer group gets the background color and full-bleed padding

**Inner group attributes:**
```json
{
  "layout": {"type": "constrained"},
  "style": {
    "spacing": {
      "blockGap": "var:preset|spacing|medium"
    }
  }
}
```

The inner group constrains content to a max-width and provides vertical
spacing between child blocks via `blockGap`.

## Cover Block Requirements

Cover blocks are the most attribute-dense and error-prone. Required attributes:

```json
{
  "dimRatio": 55,
  "overlayColor": "primary-alt",
  "isUserOverlayColor": true,
  "minHeight": 90,
  "minHeightUnit": "vh",
  "contentPosition": "bottom center",
  "align": "full",
  "style": {
    "spacing": {
      "padding": { ... },
      "margin": {"top": "0", "bottom": "0"}
    }
  }
}
```

The rendered HTML must include matching classes:
- `has-background-dim` (always present with any dimRatio)
- `has-background-dim-NN` where NN matches `dimRatio` exactly
- `has-{color-slug}-background-color` matching `overlayColor`
- `has-custom-content-position is-position-bottom-center` when using contentPosition

**Critical:** `isUserOverlayColor: true` is required. Without it, the block
editor ignores the specified overlay color.

## Spacer Blocks — NEVER Use

Do not use `<!-- wp:spacer -->` blocks for vertical spacing. Instead, use
`blockGap` on the parent group/container to control spacing between child blocks.

If specific spacing is needed between two particular elements, wrap them in a
group with the desired `blockGap` value.

## Emoji — NEVER Use

Do not use emoji characters anywhere in pattern files. Use inline SVG icons
instead. The Elayne theme references Heroicons, Feather Icons, and Lucide Icons
as design sources for SVG icons.

## Whitespace Rules

**Between closing div and block comment:**
No whitespace or newlines between `</div>` and `<!-- /wp:... -->`. They must
be immediately adjacent:

```php
<!-- CORRECT -->
</div>
<!-- /wp:group -->

<!-- WRONG — has a newline between them -->
</div>

<!-- /wp:group -->
```

**Between HTML comments and div tags:**
No extra HTML comments or whitespace between `<div ...>` and the next
`<!-- wp:... -->` child block comment.

## PHP Unicode

In PHP single-quoted strings, `\uXXXX` escape sequences do not work.
Use actual UTF-8 characters directly:

```php
// CORRECT
esc_html_e( 'Day Spa · Wellness Retreat', 'elayne' );
esc_html_e( 'Mon – Fri: 9am – 6pm', 'elayne' );

// WRONG — \u escapes are literal in single quotes
esc_html_e( 'Day Spa \u00B7 Wellness Retreat', 'elayne' );
```

## Button Structure

Buttons have a specific attribute structure that differs from other blocks:

```
<!-- wp:button {"backgroundColor":"primary-accent","textColor":"primary-alt","style":{"border":{"radius":"var:preset|border-radius|sm"},"spacing":{"padding":{"left":"var:preset|spacing|medium","right":"var:preset|spacing|medium","top":"var:preset|spacing|small","bottom":"var:preset|spacing|small"}},"typography":{"fontWeight":"600","fontSize":"var:preset|font-size|base"}},"fontFamily":"body"} -->
```

Note:
- `fontSize` is inside `style.typography`, not at root level
- `fontFamily` is at root level
- `backgroundColor` and `textColor` are at root level
- `border.radius` uses a preset variable

The rendered HTML must include all corresponding classes:
`has-primary-alt-color has-primary-accent-background-color has-text-color has-background has-body-font-family has-custom-font-size wp-element-button`

## Images

For images within patterns, use `get_template_directory_uri()` for theme assets:

```php
<?php echo esc_url( get_template_directory_uri() . '/assets/images/placeholder.webp' ); ?>
```

Never use external image URLs. Never use real photograph URLs. Use placeholder
images from the theme's assets directory.

## Email Addresses

All email addresses in patterns must be fictional: `info@example.com`,
`contact@example.com`, etc. Never use real email addresses.

## Font Families

Three font family slugs are available:
- `body` — Jost (used for body text, buttons, UI elements)
- `decorative` — Cormorant Garamond (used for headings, display text)
- `display` — Barlow Condensed (used for eyebrows, labels, condensed text)

Set via `fontFamily` attribute at root level of the block comment.
