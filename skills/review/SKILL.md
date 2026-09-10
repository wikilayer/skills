---
name: review
description: "Reader-perspective review of a wikilayer wiki, or of one page in it: does the whole hang together as one coherent body of work? Checks structural coherence across pages, contradictions, missed DRY, reading rhythm, and what the text would say in fewer words. This is the editor's read, wording included; the mechanical pass over the house antipattern list is the wikilayer lint skill. Advisory only; never edits. A wiki target is expensive, for major releases or a quarterly pass; a page target is cheap and is the usual read right after one page was added or reworked. Use when the user asks to review a wiki or a single page, audit it as a reader, check it for coherence, or ask what it would say in fewer words."
---

# wikilayer:review

Advisory reader-perspective audit. Where lint runs a fixed antipattern checklist over the tree, review is the editor: it reads the text itself and checks that the whole is coherent, consistent, non-contradictory, and no longer than it needs to be. Recommendations only. Do not edit.

## Procedure

1. Resolve the target from the user's request (numeric id, URL, or unambiguous wiki/page name). If it is missing or ambiguous, ask.

   **Scope: whole wiki or one page.** The target may be a whole wiki or a single page (its subtree). Read its `kind` with `get_outline` or `get_node`. A `wiki` target runs the full procedure; a `page` target reviews only that page and its blocks (the per-page categories below) and skips the wiki-level synthesis in step 4, which needs the whole tree. Reach for a page target when one page was just added or reworked; use a wiki target for the periodic whole-body pass.

   **Pick the language facet.** `get_outline` rows carry a `language` field; collect the distinct languages present. If the wiki is monolingual, the whole wiki is the facet and the rest of this procedure runs unchanged. If it is multilingual, this skill audits one language at a time: take the target language from the user's request (for example `wiki 1 in en`), otherwise default to the wiki's primary language (the root's language). Every step below operates on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page target is already one language, so it needs no facet choice.

   A language twin is the same topic in another language, never a finding. A page and its translation are not a contradiction, not missed DRY, not a duplicate. Checking a translation against its source is the job of `wikilayer:translations`, not this skill, so nodes outside the target facet stay out of scope for this run.
2. Read and accept any rules the Wikilayer server requires before protected reads, then carry the returned agreement token on every call it binds. Read the complete outline with `get_outline(<wiki-id>, max_depth=10)`, supplying the pagination arguments exposed by the client and continuing until `has_more` is false. Use it as the structural map of the facet; on a multilingual wiki the facet home is the target language's home (the wiki root for the primary language, the root's translation twin for another). Tool names may be namespaced by the client; use the exposed Wikilayer tool whose final name matches the operation named here.
3. Spawn one general-purpose subagent per page, passing each the agreement signature from step 2 and requiring it on every call that binds it. Each subagent reads the page's **exact** content with `get_page_markdown(<page-id>)`, in reading order already. It runs the per-page categories below and returns a verdict in two parts.

   The first part is the findings: a proof-of-work line per clean block, full evidence (cited quote + block URL, plus the shorter version where the finding is a cut) per finding. The second is a digest of the page, and it is what the wiki-level pass runs on: every substantive claim the page states, one line each, carrying its block id and the number, date, name or rule it asserts, followed by the subjects the page treats at length. Without the digest step 4 has nothing to collate. A contradiction between two pages lives in what each of them claims, and once the pages have been read in parallel nobody holds the claims of both.

   The fan-out is mechanics, not a division of the task. A whole wiki does not fit one context and an exact-text audit cannot run on a summary, so the pages are read at once and only their digests come back. Say this when reporting: the deliverable is one review of the whole body, and the per-page reads are how it was produced.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md` URL. WebFetch routes the page through a model that can silently reword or reorder content, which corrupts an exact-text audit (a block list was observed reordered this way). The tool returns the stored markdown untouched.

   Two things in that document are the engine's, not the author's: the `<!-- block:N -->` comment above each node, which is how a finding cites the node it belongs to, and the closing `## Links here` section after a `---` rule. Neither is ever a finding, and the rule before the section is not a heading smuggled into a body. Whether anything points at the page at all is the wikilayer lint skill's call, not this skill's.
4. **(Wiki target only.)** Synthesize the wiki-level pass from the digests once every subagent has reported: cross-page contradictions, missed DRY, and structural grouping, all within the target facet. The caller does this; it is the only step that holds every page at once, and it is what a wiki target is bought for. Skip it and the run is a stack of page reviews, which is what the target was chosen not to be.

   Before reporting a contradiction, re-read the two blocks it names with `get_page_markdown`. A digest is a summary, and a summary can manufacture both an agreement and a conflict that the text does not hold.
5. Emit one markdown report grouped by category. Caller never writes back to the wiki.

## Categories

Per-page (subagent judges):

1. **Headings as a coherent table of contents.** Read block titles of the page in order, as if they were a chapter list. Do they together tell a connected story? Pure outline-level read, not body-deep. Adequate titles are the primary structure on this wiki; if the chapter list reads as a story, no opening hook is needed.

   Read the h2 titles as the chapter list they are: each names a section of the page, in a few words, and a page opening on its frame ("Intro", "Who this page is for") is a normal first chapter. Two shapes break the list. A top level written as sentences reads as a stack of claims rather than a table of contents, and a page whose whole top level is sentences was made in one pass with no sections at all: say which sections its blocks fall into. Deeper down the opposite is the fault — a heading that promises nothing over a body that states something, so the claim never reaches the outline and the block is found only by opening it.
2. **Reading rhythm within each block.** Subagent reads each block as prose, not as a checklist. Even when the block isn't mechanically a wall (lint catches that), does it lose the thread mid-way? Topic jumps, missing connective tissue, paragraphs that don't continue the previous one, flag.
3. **Text that would say the same in fewer words.** A long block gets skimmed, so every word that adds nothing costs the block its reader; the reason behind a claim is one or two sentences near the top, and everything after that is shorter or gone.

   Write the shorter version where there is one: quote what goes, show what stands. A verdict with no rewritten text is not a finding, and a cut is worth reporting only when the shorter version is visibly shorter and still says everything the original said. A claim restated in new words, and a line that would be true under any heading, are the usual material.

   A block already as short as its claim allows earns a proof-of-work line and nothing else: this is the check most prone to inventing work. Where lint would split a long block into children, that is lint's call; this one asks what the block says in fewer words at whatever size it ends up.

Wiki-level (caller synthesizes):

4. **Contradictions across pages.** The same number, date, name, or fact stated differently in two places. For fiction or mystifications: the wiki should be internally consistent even when it is consistently making things up. Compare only within the language facet; a fact that reads differently in a page and its translation twin is a translation matter for `wikilayer:translations`, not a contradiction here.
5. **Missed DRY.** A subject mentioned substantively in three or more places, with no dedicated root page; recommend extracting. Count mentions within the facet only: a page's translation twin is the same mention in another language, not an additional one.
6. **Sibling-blocks asking for a common parent.** Among the direct children of a page, two or more share an evident subtopic and would read better re-parented under a new intermediate block. Look at sibling title clusters.

## Evidence requirement

Every finding carries a citation: block URL plus the specific quote, title list, or shorter rewrite that demonstrates the issue. A subagent verdict of "looks fine" without proof-of-work is not acceptable; re-spawn that page if the verdict is thin.

## Severity

- **High**: contradictions; broken structural coherence (titles that don't add up to a chapter list).
- **Medium**: missed DRY; sibling-grouping opportunities; a body spending more words than its claim needs.
- **Low**: rhythm hiccups; phrasing judgment calls.
