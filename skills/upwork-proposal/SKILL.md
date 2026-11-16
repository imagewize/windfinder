---
name: upwork-proposal
description: Qualify an Upwork job, research the client's actual site, draft a proposal whose first 200 characters survive the client's applicant list, decide the boost, submit it, and log it. Use when the user wants to bid on, apply to, draft, or review an Upwork proposal, or mentions "Upwork job", "should I bid", "write a proposal", "boost", or "Connects".
user-invocable: true
allowed-tools:
  - read_file
  - grep
  - bash
  - ask_user_question
  - todo
  - upwork
metadata:
  version: "1.0.0"
  source: "seo-strategy/.agents/skills/upwork-proposal"
---

# Upwork Proposal

Takes an Upwork job from "should I bid at all" to a submitted, logged proposal.

This skill exists because of one measured fact: **the client's applicant list
shows roughly the first 200 characters of the cover letter and nothing else**,
and **that text cannot be edited six hours after submission**. Everything else in
a proposal is recoverable. That sentence is not. An audit of 11 real proposals
found 8 wasted it on a greeting, a credential or a meta-sentence, against a
record of 0 hires.

The skill has two halves. The mechanics — the qualification gate, the 200-char
check, the boost arithmetic, the submit flow — live in this file and do not
change. The account-specific half — rate floor, target countries, the library of
**verified** proof points, banned phrases — lives in the **rules file**, because
a proposal that cites a number nobody can verify is worse than one that cites
nothing, and this file cannot know which numbers are real.

**Never submit without explicit user approval.** `manage_proposals` returns a
preview; `confirm_preview` executes. The gap between them is the user's decision,
not a formality to narrate past.

**Never invent a proof point.** No metric, client name, timeline or outcome that
is not in the rules file or verified in this session. This has already gone wrong
once: a draft cited fabricated TTFB figures and presented a target as an achieved
result, caught only in review.

## Modes

Chosen from the first argument.

- **Draft mode** (default) — a job id or URL. Qualify, research, draft, check,
  submit, log.
- **Audit mode** — a path to an existing draft. Score it against the checklists
  and report. Writes nothing, submits nothing.
- **Post-mortem mode** — `--sent`. Pull submitted proposals, compare their
  openers and outcomes, report what the account is learning.

## Tool use

- **Upwork MCP for everything Upwork.** `find_jobs`, `get_profile`,
  `list_freelancer_proposals`, `list_client_proposals`, `manage_proposals`,
  `confirm_preview`. Never scrape the site for something a tool returns.
- **`read_file` for files**, with offset and limit. Not `cat`, `sed`, `head`.
- **One plain command per call.** No loops, no `$(…)`.
- The one exception is the 200-character check, which is a single `head -c`.

## Instructions

### Phase 0: Preparation

1. **Load the rules file.**

```bash
ls -d .agents/upwork-proposal.md .vibe/upwork-proposal.md
```

   Read the first that exists, in full. It is authoritative: its **Facts**
   override anything inferred, its **Proof library** is the only source of
   citable results, and its **Rules** are applied before anything in this file.

   Also read, when they exist and the task touches them:
   `outreach/upwork/proposals.md` (house rules and templates),
   `strategy.md` (job filter), `proposals-sent.md` (what has been tried).

2. **Read the account state.** Never guess a balance or a rate.

   - `get_profile` action=`connects_balance` — Connects available now.
   - `get_profile` action=`get` — profile rate, title, skills, Top Rated status.

   Print it before going further:

```
ACCOUNT
Connects: 69 (47 free + 22 paid)     Profile rate: $60/hr
Top Rated · 100% JSS · 38 jobs · Rules: .agents/upwork-proposal.md
```

3. **Resolve the argument.** Let `TOKEN` be the first word after the skill name.

   - No argument → ask which job. Do not browse.
   - `--help` → print Modes and usage. Do nothing else.
   - `--sent` → post-mortem mode.
   - An existing file path → audit mode on that draft.
   - All digits, or a `~02…` / `upwork.com/jobs/…` URL → draft mode on that job.
     Pass the **numeric** id to `find_jobs` action=`get`; `job_reference` on
     `manage_proposals` wants the numeric id, not the ciphertext.

### Phase 1: Qualify — a real gate, not a formality

4. **Pull the job and the client.** `find_jobs` action=`get`.

   Record, and state each one: applicant count (`proposals_tier`), posted time,
   budget and type, experience level, client country, payment verified, client
   rating and review count, total spent, hire rate, **average hourly rate paid**,
   and whether the post carries **screening questions**.

5. **Score it against the rules file's filter** and print a verdict table. The
   thresholds live in the rules file; these are the axes:

   | Axis | Why it decides |
   |---|---|
   | Applicant count | Clients open ~1 proposal in 40 on long lists. Measured: 34/35, 39/40 and 55/55 unopened. |
   | Screening questions | They force the client to read. The one long-list proposal ever opened was on a job with four mandatory questions. |
   | Client average paid | A $13.86/hr history does not convert a $45/hr bid, however good the writing. |
   | Client spend + hire rate | $0 spent and 0% hire rate is an unproven buyer, not a bargain. |
   | Country | Timezone overlap decides whether same-day back-and-forth is possible. |
   | Lane | Moat lane (WooCommerce, Core Web Vitals, Trellis/Bedrock, migrations, payments) vs commodity page-builder work where 15 years is invisible. |

6. **State GO or NO-GO before writing a word.**

   A NO-GO ends the skill. Say which axis failed and what it would take to
   change. Do not soften it into a draft "just in case" — a proposal costs
   Connects, and the whole point of the gate is that the writing cannot rescue a
   bad job. **If the user overrides a NO-GO, say so in one sentence, record it in
   the log entry as a deliberate exception, and proceed in full.**

### Phase 2: Research — earn the first sentence

7. **Find something true about *their* situation.** This is what the opener is
   made of, and it is the single biggest differentiator available.

   - If the post names a URL, look at it. Response headers, cache status,
     redirects, obvious stack tells. One verified finding beats three paragraphs.
   - If the post names symptoms but no URL, connect two of their own symptoms
     into one likely cause, and label it a hypothesis.
   - If the post has screening questions, answer them concretely — that is both
     the research and the forced-read mechanism.

   **Label certainty honestly.** "I checked X on your site this morning" is only
   allowed if it was actually checked this session. Otherwise: "usually",
   "my working hypothesis", "I would confirm before touching anything."

### Phase 3: Draft — the opener is a separate deliverable

8. **Write line 1 first, alone, before any other sentence.** Do not write the
   body and then extract an opener from it; that is how greetings and credentials
   end up in the window.

   Line 1 must be:
   - **≤150 characters**, a complete standalone sentence ending in a period.
   - **About them** — their symptom, their site, their two problems that are one
     problem. Never "I can…", never "I specialise…", never a name or greeting,
     never a language-preference note.
   - Followed by a **blank line**.

   Worked examples from the archive — the two that got this right:

   > "Desktop's protected and dialed in, mobile isn't, and first paint is running 3-4 seconds — that's usually two separate problems wearing one ticket." (145)

   > "I checked the two things you flagged on golfyr.com this morning, and they're connected." (86)

   And the ones that did not, each of which went unopened:

   > "I can deliver exactly what you've described…" — about Jasper.
   > "To answer both questions directly first:" — a sentence about sentences.
   > "Bonjour, je vous écris d'abord en français…" — the whole window spent on a courtesy note.

9. **Then the body**, following the rules file's tone and the templates in
   `outreach/upwork/proposals.md`:
   diagnosis → `→` list of actual checks → **one verified proof point from the
   rules file** → a cheap closing question. Target 120–180 words after the opener.

   If the job is in Dutch, German or French, write it in that language. Lead with
   the *diagnosis* in that language — one line doing both jobs — not with an
   offer to switch languages.

### Phase 4: The 200-character gate — a hard stop

10. **Write the cover letter to its own file, containing nothing else**, and
    check that. The draft files in `drafts/` carry a `JOB:` / `CLIENT:` header and
    `FIT NOTES` above a `---PROPOSAL TEXT---` marker — running the check on the
    draft file measures the header, not the letter, and silently passes garbage.

    Write exactly what will be pasted into Upwork to a sibling file,
    `<slug>.letter.txt`, first line = line 1, no header, no markers:

```bash
head -c 200 <slug>.letter.txt
```

    (`head -c` counts bytes, so accented text shows slightly *less* than the
    client will — conservative, which is the right direction.)

    The `.letter.txt` file is also what gets pasted, so it doubles as the
    paste-ready artifact. Keep both: the draft carries the reasoning, the letter
    carries what was actually sent.

11. **Print that slice verbatim in the conversation, inside a fence**, and judge
    it against three questions:

    - Does the first sentence resolve completely inside the window?
    - Is it about the client?
    - Read cold, with no other context — would it earn a click over 39 others?

    **If any answer is no, rewrite and run it again.** Do not proceed to submit
    with a failing slice, and do not ask the user to approve one. There is no
    later fix: cover-letter editing closes six hours after submission, verified
    in the browser — the field renders read-only and only the bid stays editable.

12. **Mechanical checks, all blocking:**

    - **No underscores anywhere.** Upwork's editor read `wcml_client_*` as
      formatting and saved it mangled.
    - **No hard-wrapped paragraphs** — single-line paragraphs, so it pastes clean.
    - **No fabricated numbers.** Every figure traceable to the rules file.
    - **No em-dash-free reformatting of quoted client text** — quote them exactly.
    - Targets and achieved results are labelled as such, never conflated.

### Phase 5: The boost decision

13. **Prepare the proposal** with `manage_proposals` action=`create`. The preview
    returns `connects_cost`, `connects_balance`, `bid_stats`, and a `boost` block.

14. **Read `boost.current_top_bids` — the real competing bids — and decide:**

    | State | Action |
    |---|---|
    | `boost.available` false | No boost. Say why (`boost.reason`). |
    | Empty / low bids | Take a slot at `boost.recommended_connects` (often 1–5). Cheap, worth having. |
    | >10 Connects to reach the top four | **No boost — and reconsider the job.** An expensive auction is a crowding signal, not a price. |
    | A "position 1" tier at 30–52 Connects | Never. |

    **A boost never rescues a weak opener.** There are four slots per job, and the
    boost is metered in impressions, not time: it ends once the client opens it
    3× without acting or merely *sees* it 5× without interacting. It buys about
    five chances for the 200-char snippet to work. Multiplying a bad opener by
    four top slots produces five wasted impressions and a Connects bill.

    Upwork also runs random **placebo auctions** where no proposal on the job can
    be boosted; the boost table shown is then meaningless and nothing is charged.

### Phase 6: Submit

15. **Present the full preview and ask.** Always state, explicitly:
    the bid, `connects_cost`, the boost bid if any, `connects_balance` before and
    after, and the 200-char slice one final time.

16. **Ask about attachments and highlights** — never skip this. `get_profile`
    action=`list_highlights` lists portfolio projects and certificates; pass the
    chosen ids. For a file, `start_attachment_upload` with context `proposals`.

17. **Only after an explicit yes**, call `confirm_preview`.

18. **Verify what Upwork actually stored**, don't assume the send succeeded:
    `list_freelancer_proposals` action=`list`. Check `terms.chargeRate` and, if
    boosted, `terms.connectsBid` — that is the figure Upwork stored, not the one
    sent. Report any difference; it cannot be changed afterwards.

### Phase 7: Log it

19. **Append an entry to `outreach/upwork/proposals-sent.md`** in
    that file's existing template, and include the two variables now under test:

    - **Line 1 character count** and the 200-char slice as sent.
    - **Applicant count at bid time.**
    - Client average paid, boost decision and reasoning, Connects spent,
      balance after, and a link to the draft file.

    Keep both files in `outreach/upwork/drafts/`:
    `upwork-YYYY-MM-DD-slug.txt` (header, fit notes, reasoning) and
    `upwork-YYYY-MM-DD-slug.letter.txt` (exactly what was submitted). The second
    is the permanent record of an unchangeable artifact — never edit it after
    submission, since the live proposal can no longer be edited to match.

---

## Qualification Checklist

Applied in Phase 1. The rules file sets the numbers; it may disable any line.

- Applicant count within the ceiling, **or** the post has mandatory screening
  questions.
- Posted recently enough that the list is still short.
- Payment verified.
- Client rating ≥4.0, or unrated with real spend history. A **low** client rating
  is a warning about the client — freelancers gave them that score.
- Client average hourly paid within reach of the intended bid.
- Country in the target set.
- Lane is moat, not commodity.
- Budget is not a posted range whose top sits below the rate floor — that range
  is a signal to skip, not to discount into.

## Opener Checklist

Applied in Phase 3 and re-checked in Phase 4.

- ≤150 characters, one complete sentence, ends in a period, blank line after.
- First word is not a greeting, a name, "I", or a meta-phrase.
- Names their symptom, their site, or their own words back to them.
- Would stand alone as a LinkedIn hook — same fold, same job.
- Contains no underscore, no fabricated figure, no unverifiable claim.
- If a finding is asserted, it was verified this session; if not, it is hedged.

## Body Checklist

- 120–180 words after the opener.
- Every claim traceable to the rules file's proof library.
- Targets labelled as targets; achieved results labelled as achieved.
- A `→` list of the real checks, in the order they would run.
- Screening questions answered directly and first, if the job has them — but
  never with "to answer your questions" as the opening line.
- Closes on a question the client can answer in one line.
- Rate stated, with the reasoning if it sits above the posted range.
- Single-line paragraphs; no manual wrapping.

## Post-mortem Checklist (`--sent`)

- `list_freelancer_proposals` for each status, not just the default.
- For each: line 1 length, whether the snippet was wasted, applicant count,
  boost decision, viewed or not, outcome.
- Decode the Connects ledger: `itm` = in the money, boost won and was charged;
  `otm` = out of the money, outbid and refunded.
- Report what correlates with a view. Resist a story from three data points —
  say when the sample cannot support the conclusion.

---

## The rules file

Lives at `.agents/upwork-proposal.md` (fallback: `.vibe/upwork-proposal.md`),
versioned alongside the work it governs. `.agents/` is deliberate: it is not tied
to one tool, so the same rules serve Vibe, Claude Code or anything else, while
`.vibe/` would bind them to one CLI.

Every section is optional, but the **Proof library** is what keeps the skill
honest — without it, the drafting step has nothing true to cite and will reach
for something plausible instead.

```markdown
# Upwork proposal rules — <account>

<One paragraph: who is bidding, what they sell, what they will not take.>

## Facts
- Profile rate, Top Rated status, languages, timezone and the EU overlap window.

## Filter
- Applicant ceiling, rate floor, target countries, moat lane, client-quality bar.

## Proof library
- <Client> — <engagement shape>, <verified numbers>, <what is a target vs achieved>.
  Source: <where this was verified>

## Tone
- <House voice: what it sounds like, what it never does.>

## Banned phrases
- <Opening lines that have measurably failed.>

## Rules
- <Rule.>
  Why: <the concrete failure when it is broken>
```

The **Why** line is what a draft is checked against; a rule without one can only
be asserted, not verified.

---

## Setup

**Install.** The skill lives at `.agents/skills/upwork-proposal/` in this repo,
matching the code-review skill in `~/code/aludra/.agents`. Vibe discovers it with
no configuration: it searches `skill_paths` from `config.toml`, then the project's
`.vibe/skills/` **and** `.agents/skills/`, then `~/.vibe/skills/`, keeping the
first skill it finds for a name. **No `skill_paths` entry is needed.**

`.agents/` rather than `.vibe/` because it is tool-neutral — this repo already
carries two parallel copies of the same marketing skills in `.claude/skills/` and
`.vibe/skills/`, which is exactly the drift `.agents/` avoids. Invoked as
`/upwork-proposal` once `user-invocable: true` is set, which it is.

**MCP.** `config.toml` carries only machine settings — tool permissions, models,
MCP servers. No rule from this skill belongs in it: TOML holds an allowlist, not
a rate floor or a proof library, and those need the "why" line that makes them
checkable. Same split as aludra, whose `.vibe/config.toml` is a bash allowlist
and nothing else.

The Upwork server is already configured in this project's `.vibe/config.toml`:

```toml
[[mcp_servers]]
name = "upwork"
transport = "http"
url = "https://mcp.upwork.com/mcp"

[mcp_servers.auth]
type = "oauth"
scopes = []
```

**Permissions.** Three tool classes matter, and they are set differently on
purpose. All of this is already in `.vibe/config.toml`.

| Class | Setting | Why |
|---|---|---|
| `bash` | already allowlisted | The only command is `head -c 200`. `head`, `ls`, `grep`, `wc`, `cat` are in the project list. |
| `write_file`, `edit` | `ask` + path allowlist | The project overrides the global `always` down to `ask`. Rather than loosen that, the drafts directory and the send log are allowlisted by path, so the skill writes its own artifacts without prompting and nothing else. |
| Upwork **read** tools | `always` | Nine of them run per proposal; prompting on each makes the skill unusable. |
| Upwork **write** tools | `ask` — left alone | `manage_proposals`, `confirm_preview`, `update_profile`, `send_message`, `boost_profile` spend Connects or act in Jasper's name. The prompt is the safety, and Phase 6 is written to stop at it. |

**MCP tool naming.** Vibe keys MCP tools as `{server}_{tool}` — verified against
the wp_ops server in this repo, where Claude's `mcp__wp-ops__wp_cli` appears as
`wp_ops_wp_cli`. The Upwork server prefixes its own tool names with `upwork__`,
so the keys double up: `upwork_upwork__find_jobs`.

⚠️ **Prerequisite: the Upwork MCP server must actually be connected in Vibe.**
Listing tools in a Vibe session on this repo returns the `wp_ops_*` tools but
**no `upwork_*` tools at all** — the server is declared in `.vibe/config.toml`
with `auth.type = "oauth"`, and that OAuth flow has not been completed there.
Until it is, this skill cannot run in Vibe regardless of permissions. Complete
the auth from an interactive session, then re-list the tools and confirm the
names above match; correct them in `config.toml` if the server reports different
ones.

Note that a project `allowlist` **replaces** the one in `~/.vibe/config.toml`
rather than merging with it, so if the project list is ever rewritten, keep
`head`, `ls`, `grep` and `wc`.

## Tips

- Run it on a job *before* deciding to bid. The gate is the cheapest part.
- `--sent` after a batch of bids is where the learning is.
- If the opener is hard to write, that is usually the job telling you it was a
  NO-GO. A job you have nothing specific to say about is a job you are guessing on.
- Keep the draft file even when the answer is NO-GO — the qualification note is
  worth more later than the draft would have been.
