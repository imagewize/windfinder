---
name: linkedin-content-planner
description: "Plan 2-5 LinkedIn posts per week: pillar mix, format, hook formula, angle and posting time per post, a recycling slot for proven past posts, plus daily comment targets. Use when the user asks what to post this week, wants a content calendar, or wants a steady posting rhythm instead of ad-hoc posts. Plans only — the user posts by hand."
user-invocable: true
license: MIT
metadata:
  version: "1.0.0"
  source: "github.com/sergebulaev/linkedin-skills @ 8f8bc4b40a2d5419b2dcf898772b85712cfbdf41 (MIT, LICENSE copied alongside; content-planner logic ported and condensed, Publora/Apify backends dropped — manual only)"
---

# LinkedIn Content Planner

Produce a weekly LinkedIn plan built around a small pillar set, with a fixed cadence, a
recycling slot for posts that already performed, and a daily comment lane. Planning beats
ad-hoc shipping: a calendar that mixes formats and goals reaches further than one-off
inspiration.

Manual only: this skill plans. The user writes posts (see `linkedin-post-writer`), posts,
and comments by hand.

> Project conventions (AGENTS.md, a social-media doc in the project repo) override the
> defaults below — e.g. a project may ban hashtags or links in post bodies. When they
> exist, follow them and say so in the plan.

## When to use

- "What should I post this week?" / "plan my week" / "give me a content calendar"
- Establishing a rhythm (2-5 posts/week) instead of posting sporadically
- Before a launch or offer week (needs an offer-pillar slot)
- When reach is flat and the user suspects cadence or mix, not topic

## Inputs

- **Audience:** who the posts are for (e.g. "SME shop owners in NL/EU", "B2B founders")
- **Pillars** (optional): defaults below
- **Posting days/times** (optional): default Tue/Wed/Thu, audience-timezone morning
- **Content inventory** (optional): existing posts, blog articles, case studies, visuals
  that can be recycled or repurposed
- **Performance tracker** (optional): if the project keeps one (e.g. a markdown table of
  past posts with impressions at a recorded age), read it and recycle from the top rows

## Default pillar mix

| Pillar | Share | What it is | Typical formats |
|---|---|---|---|
| **Authority / buyer-pain** | 40-50% | Frameworks, data takes, teardowns, dated-rule or market news applied to the audience's business | Text, carousel, single image |
| **Personal narrative / behind-the-scenes** | 30-40% | Real client work, failures, tests, decisions — the first-hand material | Text, multi-image, short video |
| **Community / conversation** | 20-30% | Reply-to-a-peer posts, polls, spotlights, questions | Text, poll |
| **Offer / product** | max 1 post/week (10-15%) | A soft, ignorable offer tied to the week's topic | Text + visual |

Guardrails:

- 3 pillars minimum, 5 maximum. No pillar above 60% of the week.
- **2-5 posts/week.** 6+/week (or 2+/day) triggers cannibalization in the feed.
- One format per pillar per week — vary text / image / carousel / poll.
- Reserve **one slot per week for the reply-to-a-peer format**: answer a named peer's post
  with your own finding. Posts that enter an existing conversation reach further than
  monologues (their network sees it too, and the first hour gets a built-in audience).
- Never repeat the same hook formula twice within 7 days.

## Cadence and timing

- **Default windows (audience timezone):** Tue/Wed/Thu 7:30-9:00 AM local. EU
  decision-makers: Tue/Wed 7:00-8:30 AM CET.
- Avoid Mon before 9 AM, Fri after 2 PM, weekends (B2B reach drops 30-50%).
- One post per slot; always record the exact posting time — it is needed to compare
  posts fairly later.
- First 60-90 minutes decide most of a post's reach: plan to be around to reply to every
  comment within 90 minutes of posting (seed one substantive self-reply if the room is
  empty), and plan the day's comment lane for the same window.

## Recycling protocol

Re-running a proven post is cheaper than inventing a new one — but never verbatim:

1. Pick from the performance tracker's top rows (highest impressions **at the same age**
   as the others being compared** — reach keeps accruing for weeks, so a 3-day-old number
   understates a post by ~2x; only compare equal ages**).
2. Wait at least **10-12 weeks** before re-running a post.
3. Change the wrapper, keep the spine: new hook line, a new dated fact or number, an
   updated visual (or reuse the old one if it is still accurate).
4. Log the re-run as a new row in the tracker (new date), and note "re-run of <date>" so
   the comparison is explicit.

## Daily comment lane (part of the plan, not optional)

Comments on other people's posts often out-reach own posts:

- 3-5 target creators per posting day (archetypes: peers in the audience's lane, slightly
  larger accounts whose readers are your audience)
- Comment on posts **under 24 hours old with roughly 20-100 comments**; early, substantive
  comments on mid-sized posts beat late comments on huge threads
- 2-4 sentences, one concrete fact/number/experience, no pitch, no link; match the poster's
  language
- 10-20 substantive comments per day max; never automate

## Output

A markdown week plan:

| Day | Time (audience tz) | Pillar | Format | Hook formula | 1-line angle | Goal |
|---|---|---|---|---|---|---|
| Tue | 08:00 CET | Authority | Image | F7 number-first | "..." | Saves |
| ... | | | | | | |

Plus per day: 3-5 comment targets with the pattern to use (first-commenter / data-first /
answer-their-question), and a weekly checklist:

- [ ] At least 1 first-hand proof post (a test, a client story, a number you measured)
- [ ] At least 1 reply-to-a-peer or recycled top performer
- [ ] At most 1 offer post, framed as ignorable
- [ ] No pillar >60%, no formula repeated within 7 days
- [ ] Goals spread across the week (saves / comments / reposts / likes), not all the same
- [ ] Exact posting time recorded per post; analytics to be read at 1d / 3d / 1w / 30d

## Steps

1. Gather inputs (audience, inventory, tracker if any). Ask only for what is missing and
   materially changes the plan.
2. Read the tracker's top rows if one exists; pick the recycle/reply candidates.
3. Lay out the week: pillar per slot, format, formula (see
   `linkedin-post-writer` → `references/hook-formulas.md`), angle from real material —
   never invent a figure that is not in the inventory, the tracker, or supplied by the
   user.
4. Add the comment lane per posting day.
5. Run the weekly checklist; flag anything missing.
6. Return the plan as markdown. Hand each post slot to `linkedin-post-writer` for drafting.

## Files

- `SKILL.md` — this file
- `references/pillars-framework.md` — the pillar discipline in full
- `references/cadence-and-recycling.md` — cadence, timing, recycling and measurement rules

## Related skills

- `linkedin-post-writer` — draft each planned post (new or repurposed)
- `linkedin-comment-queue` — work the daily comment lane by hand
