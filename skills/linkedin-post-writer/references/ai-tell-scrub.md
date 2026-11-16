# AI-tell scrub pass — adapted from sergebulaev/linkedin-skills (humanizer + voice-rules, MIT, pinned 8f8bc4b), condensed

Run on every draft before the approval card. The unit of judgement is the **paragraph**:
count markers per paragraph, rewrite at 3+, leave a single marker alone unless it is a
reveal bridge or hard leakage. Edits proportional to real problems — do not flatten the
voice ("writing slightly worse on purpose" is itself a tell).

## Hard leakage (always remove)

- AI tool markers and citation artifacts (oaicite, contentReference, turn0search0, …)
- Knowledge-cutoff disclaimers ("As of my last update...")
- Template placeholders ([Your Name], 2025-XX-XX)
- Outline-formula closers ("Despite its X... Looking ahead...")

## Density rules

- **Em dashes: ~1 per 100 words max** (0-1 in a short post). Replace excess with comma,
  colon or parentheses — never a period. No en dashes between clauses, no `--`.
- Use `..` as a soft pause instead of a second em dash.
- One contrast + one triple per post (see hook-formulas.md Density rule)
- Max 2 standalone sentence fragments per post; never alternate long/short across the
  whole post

## Vocabulary blacklist (never in a post)

leverage, utilize, facilitate, streamline, robust, seamless, delve, navigate, unlock,
harness, foster, cultivate · fundamentally, essentially, ultimately, crucially, notably ·
landscape, ecosystem, paradigm, realm, tapestry, journey · "It's not just X, it's Y" ·
"In today's fast-paced world" · "game-changer", "deep dive", "at the end of the day"

## Structure rules

- 1-2 sentence paragraphs, blank line between ideas
- One line per idea that could be screenshot and quoted standalone
- End with a specific question or a clean landing — never "What do you think?"
- Capitalize personal, company and product names

## Framing tells

- No announced candor ("Let me be honest", "Confession:") without a dated fact behind it
- No reveal bridges ("The result?", "Plot twist:", "Here's what nobody tells you")
- No generic praise or thesis restatement (in comments)
- Passive voice under 10% of clauses
- "How I" over "How to"

## Keep (these are human, not tells)

- Real numbers, named entities, first-person concrete details — at least one each per
  ~100 words
- The user's actual voice quirks, lowercase sentence starts if that is their style
