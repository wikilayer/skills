---
name: lint
description: "Final polish of a Wikilayer page or wiki after review has finished and substantive edits are settled. Checks wording, marks, links, voice, quotations, and prose flow. Advisory only; never edits."
---

# wikilayer:lint

Advisory pass over the surface of the text. It is the last of three steps: the author reads every touched page whole, then review runs until nothing left changes what the wiki asserts, then this. Run it only once changes to claims or structure are settled. Read each block, apply the check list, emit a markdown report grouped by page. Do not apply fixes.

This skill reads the text. Nothing it finds can become false: a mark, a phrasing, a paragraph that lost its thread is not wrong later, only worse to read, so the fix happens while the author is already in the node and never sends anyone back to re-read the page. What can become false belongs to the review skill, which reads the tree and the claims. Keep the two reports apart: merged into one list, the cheap findings crowd out the expensive ones, and the cheap ones get done because they are cheap.

The checks below mirror https://wikilayer.org/smee-again/wikilayer-howto/54729-wording-and-marks, the primary source. They are duplicated here on purpose: the skill must run self-contained against any wikilayer instance, including a localhost one with no authoring guide present, so it never fetches rules at lint time. When that page gains or changes a rule, mirror it here.

## Procedure

The caller never reads page bodies. Bodies live inside subagents; the caller only sees compact verdicts.

1. Resolve the target from the user's request (numeric id, URL, or unambiguous wiki/page name). If it is missing or ambiguous, ask. Resolve its owning wiki with `list_wikis(wiki_ids=[...])` and record `pages_tree`; never infer the setting from the current shape of the outline. A flat wiki and a hierarchical wiki can temporarily have the same shape.

   **Scope: whole wiki or one page.** Read the target's `kind` with `get_outline` or `get_node`. A `wiki` target lints every page in the facet; a `page` target lints that page and its blocks, not descendant pages. Every check runs per page either way. Use a page target for a focused pass after editing one page; a wiki target for a full audit.

   `pages_tree` does not change the prose checks, but it changes how pages are enumerated and how links are understood. When it is true, a page may sit below another page and a link to that child is not a same-page link. When it is false, ordinary pages are flat peers. State the mode in the report header so the structural context of the run is explicit.

   **Pick the language facet.** `get_outline` rows carry a `language` field. If the wiki is monolingual, the whole wiki is the facet and the rest runs unchanged. If it is multilingual, lint one language at a time: take the target language from the user's request (for example `wiki 1 in en`), otherwise default to the wiki's primary language. Every check below runs on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page target is already one language. A page's translation twin in another language is not a duplicate; checking a translation against its source is the job of `wikilayer:translations`.
2. Read and accept any rules the Wikilayer server requires before protected reads, then carry the returned agreement token on every call it binds. Read the complete outline with `get_outline(<wiki-id>, max_depth=-1)`, supplying the pagination arguments exposed by the client and continuing until `has_more` is false. No finite depth is a complete-outline request: a configured or accidental level beyond it would silently disappear from the audit. Use `tokens` and `child_count` on each row as first-pass signals to budget per-page work, and the `language` field to keep to the facet. Tool names may be namespaced by the client; use the exposed Wikilayer tool whose final name matches the operation named here.
3. Spawn one general-purpose subagent per page, passing each the agreement signature from step 2 and requiring it on every call that binds it. Each subagent reads its page's **exact** content with `get_page_markdown(<page-id>)`, runs the checks below, and returns a compact verdict: proof-of-work line per clean node, full finding with cited quote per violation. The page body never enters the caller context.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md` URL. WebFetch routes the page through a model that can reword or reorder it, which is fatal for checks like em-dash use, which only mean anything against the exact bytes. The tool returns the stored markdown untouched.

   Two things in that document come from the engine, not the author, and are never findings: the `<!-- block:N -->` comment above each node, which is how a finding cites the node it belongs to, and the closing `## Links here` section after a `---` rule.
4. Caller aggregates per-page verdicts into one markdown report, grouped by page. Caller never writes back to the wiki.

## Checks

Each is a "smart prompt": the signal flags a candidate, the agent judges whether it's a real issue in context.

1. **Em-dash.** The em-dash (`—`) is a rare mark, earned, not default punctuation. Flag every occurrence and judge whether it is the seldom case where nothing else carries the meaning; almost always a comma, colon, period, or parentheses is the fix. Do not wave `—` through as "one per page is fine".

   The paragraph above is an English convention, not a universal one, so first establish what the facet's language does with the mark. Where it is ordinary punctuation there, or required outright, the dash is spelling and this check does not run on the page at all: German sets off an aside with one freely, and Russian puts one between subject and predicate when the copula is absent, where omitting it is the error. Those two are examples and not the list — check the language in front of you rather than matching it against them, because running the English rule over a language that does not share it produces a finding on every page in the wiki.
2. **Link text.** The link text is the subject being talked about, woven into the sentence as a noun, because a reader knows subjects and not pages. Strip the links and read the sentence again: if it still states its point, the link earned its place. `Click [here](...)`, `see [the documents page](page:N)` and `details on [Other Page]` all fail that read; `[tenge](page:6564) was introduced in 1993` passes. Flag three forms: the wiki's own furniture used as the anchor ("page", "section", "see"), quotation marks around the title, and a link to one article anchored on the publisher rather than on what the article did.
3. **One-line paragraphs that should be a list.** One-sentence paragraphs in a row, sharing a parallel structure, read as sequential steps, and the reader has to work out that they belong together. Bullets carry "these belong together" for free. This is the `p` against `ul` case, and it is this skill's because the same items promoted to nodes would change the outline, which is review's call and not this one's. Where an item has grown past a line, say so and stop: promoting it is review's.
4. **Same-page links.** A link from a block to another block of the page it sits on. The reader already has that page, so the link gives nothing.
5. **Voice.** Neutral and encyclopedic: concrete numbers rather than evaluative words, and the object named. The test is whether a sentence could be moved to another wiki on another subject and still read as written; "a significant improvement" and "the exchange" survive that move, "17% fewer steps" and "exchanging dinars for forints" do not.
6. **Quotation form.** A quotation belongs in a blockquote, or it gets lost in dense prose. Where a translation is given alongside the original, the original comes first and the translation follows in italics inside the same blockquote. Whether a translation is owed at all is not this skill's call.
7. **A block that loses its thread.** Read each block as prose rather than as a checklist. Topic jumps, a paragraph that does not continue the one before it, a reason given after the thing it explains: flag the place and say where the thread breaks. Nothing here is false, only harder to follow than it needs to be.
8. **Words that say nothing.** A long block gets skimmed, so a word that adds nothing costs the block its reader. Write the shorter version: quote what goes, show what stands. A verdict with no rewritten text is not a finding, and a cut counts only when the shorter version is visibly shorter and still says everything the original said. A block already as short as its claim allows earns a proof-of-work line and nothing else; this is the check most prone to inventing work. Where the same thing is said in two places rather than at length in one, that is review's, because tomorrow one of the two is edited.

## What a finding here is worth

Every finding is the same weight: worth fixing, never worth a pass of its own. Say so in the report, and do not recommend running this skill again after the author has acted, because nothing here changes what the wiki asserts and the page that comes back is the same page.

A candidate that does not fit a check above is not a lint finding. If two places say different things, if a node sits where nobody will look for it, if a heading has swallowed its body or a body restates what the engine already keeps, hand it to the review skill rather than reporting it here. Those can become false, and something that can become false earns a second reading; these cannot, and do not.
