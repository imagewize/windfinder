---
name: linkedin-post-writer
description: "Draft a new LinkedIn post from scratch, or repurpose existing content (blog post, case study, video script, thread) into a native LinkedIn post: goal-picked hook formula, 2026 feed heuristics, AI-tell scrub, approval card. Use when the user wants to write a LinkedIn post, pick a proven hook format, or turn something they already made into a post. Manual only — the user posts by hand."
user-invocable: true
license: MIT
metadata:
  version: "1.0.0"
  source: "github.com/sergebulaev/linkedin-skills @ 8f8bc4b40a2d5419b2dcf898772b85712cfbdf41 (MIT, LICENSE copied alongside; post-writer + repurposer ported, condensed and made manual-only — Publora/Apify backends and the story-bank/voice-profile file dependencies dropped)"
---

# LinkedIn Post Writer

Draft one LinkedIn post — new from a topic, or repurposed from something that already
exists — using hook formulas with recorded 2025-2026 engagement references, the 2026
feed heuristics, and an AI-tell scrub pass. Ends with an approval card. Manual only:
the user copies the approved text and posts it by hand.

> Project conventions (AGENTS.md / social docs in the project repo) override the
> defaults — e.g. a house rule of no links anywhere and no hashtags, a fixed posting
> slot, or a required image format. When they exist, follow them and say so in the
> approval card.

## When to use

- "Write me a LinkedIn post about X"
- "Turn this blog post / case study / thread / video into a LinkedIn post" (repurpose mode)
- "What hook format should this use?" / pick from known-winning formats
- A slot from `linkedin-content-planner` needs a draft

## Inputs

- Topic + angle, or the source content to repurpose (paste it or point at a file)
- Target audience (e.g. "SME shop owners", "B2B founders")
- Goal for the post: comments / reposts / likes / saves (default: comments)
- Length preference: short 300-500 / medium 900-1,300 (default) / long 1,500-1,900 chars
- Visual: none / single image / carousel — and the project's image spec if it has one

## Steps

1. **Gather inputs** (above). In repurpose mode, extract the spine first: the one
   claim, story, or number worth keeping — keep the claim and facts intact, rebuild
   the delivery (see `references/repurposing.md`).
2. **Pick the formula by goal first**, then by topic — see
   `references/hook-formulas.md`. Offer 2-3 candidates with their reference numbers
   and 2026 caveats and let the user pick. Two rules hold regardless of formula:
   **never open with a question** (question goes at the close) and **prefer a
   number-first line**.
3. **Draft the post** respecting the 2026 heuristics (`references/algorithm-heuristics.md`):
   - Hook lands in the first **210 chars** (before the "… see more" fold); line 1 is a
     statement or a number — never a question, never "Here's what/how", never "Stop X, start Y"
   - Medium 900-1,300 chars is the default; the user's chosen length wins; hard limit
     3,000 chars. 1,000+ chars and 20+ sentences carry a reach lift, so long is fine
     when asked for
   - 1-2 sentence paragraphs with blank lines between ideas
   - Density rule: **one contrast and one triple per post max**, three sourced numbers
     or named acts (never three adjectives), zero reveal bridges ("The result?",
     "Plot twist:", "Here's what nobody tells you")
   - Every abstract line pays for itself with a specific within two lines: a date, an
     amount, a name, a percentage. Never invent one — take it from the source material
     or ask
   - Close with one specific, experience-anchored question; optional one-line P.S.
   - 0-2 hashtags max, at the end (or none — 0 hashtags performs equal to 5+ in 2026)
   - **No external link in the post body** (in-body links are suppressed ~40-60%);
     if the project allows it, the link goes in the first comment
   - Include at least one moment of real stakes or vulnerability — a dated fact, not
     announced candor ("Let me be honest", "Confession:" with nothing behind it is a
     named AI tell)
4. **AI-tell scrub pass** (`references/ai-tell-scrub.md`): cap em dashes (~1 per 100
   words), remove blacklist vocabulary and reveal bridges, break stacked triads, check
   paragraph density (3+ markers in one paragraph → rewrite it), keep the real numbers
   and named entities. Edits proportional to real problems — do not flatten the voice.
5. **Visual** (if the plan calls for one): describe it for the user to produce with
   their own design pipeline (the project may have an SVG→export script and a size
   spec). Write the **alt text** — 2-3 sentences saying what the graphic shows and
   says; accessibility and feed context both need it.
6. **Approval card** — show: mode (new/repurposed) + source mapping if repurposed,
   formula used + reference number, full draft, char count, hook char count (must be
   ≤210 before the fold), hashtags used, suggested posting window (Tue/Wed/Thu
   7:30-9:00 audience-local), visual + alt text, and the note "post by hand; reply to
   every comment within 90 minutes". Then stop and wait for approval or edits.

## Hard rules

- Never open with a question; never "Here's what/how" or "Stop X, start Y" openers
- No external links in the body; 0-2 hashtags at the end
- One contrast, one triple, zero reveal bridges per post
- No all-caps first line; intensity through word choice
- No "comment X to get Y" comment-gate phrasing (named target of LinkedIn's 2026
  authenticity enforcement)
- No invented numbers — only figures from the source material, the tracker, or the user
- One product/self mention max, and only when it is the natural conclusion, not the pitch
- Never frame LinkedIn itself as inferior in a LinkedIn post

## Anti-patterns (refuse)

- Copy-paste of the source with light edits (that is not repurposing)
- Source-platform artifacts: "link in bio", "smash subscribe", hashtag walls, "as I tweeted"
- Rule-of-three lists without receipts; "leverage", "game-changer", "deep dive",
  "in today's fast-paced world", "fundamentally"
- Em dashes above ~1 per 100 words
- Meta throat-clearing ("I originally posted this on...")

## Files

- `SKILL.md` — this file
- `references/hook-formulas.md` — the 20 formulas with skeletons, reference engagement, 2026 caveats, density rule, never-do list
- `references/algorithm-heuristics.md` — 2026 posting rules: timing, format multipliers, length, hashtags, link placement, first-hour, penalties, pre-publish checklist
- `references/ai-tell-scrub.md` — the scrub pass: blacklist, structure rules, paragraph density
- `references/repurposing.md` — source → LinkedIn transformation rules per source type

## Related skills

- `linkedin-content-planner` — the weekly calendar this post slots into
- `linkedin-comment-queue` — the daily comment lane
