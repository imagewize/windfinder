# Pattern Spec Format

A pattern spec is a structured text document that describes a pattern's content
and layout choices. It provides everything needed to generate a compliant PHP
pattern file in a single pass, skipping the HTML prototype step entirely.

## When to use a pattern spec

Use a spec when the layout archetype is already well-understood — meaning a
matching starter template exists in `templates/`. The spec describes *content
and style choices*, not block structure.

For novel layouts with no existing template, prototype in HTML first.

## Format

```
PATTERN SPEC
============
Slug: elayne/[vertical]-[pattern-name]
Title: [Human-Readable Pattern Name]
Category: elayne/[vertical], elayne/[section-type]
Template base: [template name from templates/ directory]

Style variation context: [vertical] / [description of visual tone]
Background: [color slug] or [overlay details for cover blocks]
Content position: [for cover blocks: top/center/bottom + left/center/right]

Content:
  - eyebrow: "[text]" [font size, color, style notes]
  - H1 or H2: "[text with <br> or <em><mark>...</mark></em> if needed]" [font size, font family]
  - body: "[paragraph text]" [font size, line-height notes]
  - CTA primary: "[button text]" → [href] [bg color, text color]
  - CTA secondary: "[button text]" → [href] [style: outline, text color]

SVG icons needed: [none, or description of icons needed]
Additional notes: [any special requirements]
```

## Example: Spa Hero Cover

```
PATTERN SPEC
============
Slug: elayne/spa-hero-cover
Title: Spa Hero Cover
Category: elayne/hero, elayne/spa
Template base: _hero-cover

Style variation context: spa / wellness (light, warm ivory tones)
Background: overlayColor primary-alt | dimRatio 50 | minHeight 95vh
Content position: bottom center

Content:
  - eyebrow: "Day Spa · Wellness Retreat" [x-small, primary-accent, uppercase, letter-spacing 0.14em]
  - H1: "Restore your body,<br>renew your <em><mark>spirit</mark></em>" [xx-large, decorative, base color, line-height 1.1]
  - body: "Step away from the everyday. Our therapists blend ancient techniques with modern care for total relaxation." [base, body font, line-height 1.6]
  - CTA primary: "Book a Treatment" → /book [primary-accent bg, primary-alt text]
  - CTA secondary: "Our Treatments" → /treatments [outline, base text, primary-accent border]

SVG icons needed: none
```

## Example: Plumbing Stats Bar

```
PATTERN SPEC
============
Slug: elayne/plumbing-emergency-stats
Title: Plumbing Emergency Stats Bar
Category: elayne/stats, elayne/plumbing
Template base: _stats-bar-fullwidth

Style variation context: plumbing / trade (dark, trust-building)
Background: primary (dark)

Content:
  - stat 1: "24/7" label "Emergency Service" [xx-large number, x-small label, primary-alt color]
  - stat 2: "30+" label "Years Experience" [same styling]
  - stat 3: "15k" label "Jobs Completed" [same styling]
  - stat 4: "100%" label "Satisfaction Rate" [same styling]

SVG icons needed: none (numbers are the visual)
```

## Example: 3-Column Feature Grid

```
PATTERN SPEC
============
Slug: elayne/legal-practice-areas
Title: Legal Practice Areas Grid
Category: elayne/features, elayne/legal
Template base: _feature-grid-3col

Style variation context: legal / professional (clean, authoritative)
Background: primary-alt (light)

Content:
  - section eyebrow: "Our Expertise" [x-small, primary-accent, uppercase]
  - section heading: "Practice Areas" [x-large, decorative]
  - card 1:
    - icon: scale/balance SVG (primary-accent, 48x48)
    - title: "Corporate Law" [medium, decorative]
    - body: "Strategic counsel for business formation, M&A, and governance." [small, body]
  - card 2:
    - icon: shield SVG (primary-accent, 48x48)
    - title: "Litigation" [medium, decorative]
    - body: "Vigorous courtroom representation for complex disputes." [small, body]
  - card 3:
    - icon: home SVG (primary-accent, 48x48)
    - title: "Real Estate" [medium, decorative]
    - body: "Comprehensive guidance for transactions and development." [small, body]

SVG icons needed: scale/balance, shield, home (Heroicons or Lucide style)
```

## Processing a Spec

When generating a pattern from a spec:

1. Read the template file specified in "Template base"
2. Read `references/block-json-rules.md` for all compliance rules
3. Read `references/color-spacing-presets.md` for preset values
4. Read any relevant snippets from `snippets/`
5. Generate the complete PHP file
6. Verify all text is wrapped in translation functions
7. Verify no hardcoded font sizes, colors, or spacing values
8. Add the compliance status comment at the top of the output
