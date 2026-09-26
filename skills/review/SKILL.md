---
name: review
description: "Review the coherence of a whole Wikilayer page after recent edits. Advisory only; never edits."
---

# wikilayer:review

Read the wiki as the person who came to it for something, and report what the arrangement told them. The arrangement of nodes is itself a claim: where a node sits says that these are of one kind, that this follows from that, that this is the exception. Recommendations only. Do not edit.

This skill reads as a reader; lint reads the text. Everything found here can become false, which is why a finding here earns a second reading of the page and a lint finding never does. Keep the two reports apart: merged into one list the cheap findings crowd out the expensive ones, and the cheap ones get done first because they are cheap.

**This skill does not check form.** Marks, the em-dash, wording, voice, the shape of a paragraph, a block that lost its thread or spends more words than its claim needs: all lint's, and reporting one here is a defect in the run. A typographic marker inside a body — a bold lead-in, a horizontal rule, a bullet that runs for paragraphs — is at most the trace of a claim that never became a node. The finding is the claim, quoted, and the fact that the outline does not show it; the marker is how you noticed, never what you report, and a count of markers is not a finding at all. Nothing here is decided by counting.

The categories below mirror https://wikilayer.org/smee-again/wikilayer-howto/54721-what-a-node-holds and the principles they come from at https://wikilayer.org/smee-again/wikilayer-howto/54712-principles, duplicated here so the skill runs self-contained against any wikilayer instance, including one with no authoring guide present. When either page gains or changes a rule, mirror it here.

## Procedure

Before the run, the caller reads every page the edit touched, whole, as its reader would, and fixes what that reading shows. A reviewer is for what the author cannot see from inside; a slip visible on a first reading costs a round here, and its fix opens the next one. This mirrors https://wikilayer.org/smee-again/wikilayer-howto/54798-working-in-a-wiki#block-54803.

1. Resolve the target from the user's request (numeric id, URL, or unambiguous wiki/page name). If it is missing or ambiguous, ask. Resolve its owning wiki with `list_wikis(wiki_ids=[...])` and record `pages_tree`; never infer the setting from the outline. The same current shape can be deliberate hierarchy or a flat wiki that happens to contain few pages.

   **Scope: whole wiki or one page.** Read the target's `kind` with `get_outline` or `get_node`. A `wiki` target runs the full procedure; a `page` target reviews that page and its blocks, not descendant pages, and skips the wiki-level synthesis in step 4. When `pages_tree` is true, a page review still reads the target page's immediate page parent, page siblings and child-page titles as structural context for category 2; it does not review their bodies. Reach for a page target when one page was just added or reworked; use a wiki target for the periodic whole-body pass.

   **Pick the language facet.** `get_outline` rows carry a `language` field; collect the distinct languages present. If the wiki is monolingual, the whole wiki is the facet and the rest of this procedure runs unchanged. If it is multilingual, this skill audits one language at a time: take the target language from the user's request (for example `wiki 1 in en`), otherwise default to the wiki's primary language (the root's language). Every step below operates on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page target is already one language, so it needs no facet choice.

   A language twin is the same topic in another language, never a finding. A page and its translation are not a contradiction, not missed DRY, not a duplicate. Checking a translation against its source is the job of `wikilayer:translations`, not this skill, so nodes outside the target facet stay out of scope for this run.
2. Read and accept any rules the Wikilayer server requires before protected reads, then carry the returned agreement token on every call it binds. Read the complete outline with `get_outline(<wiki-id>, max_depth=-1)`, supplying the pagination arguments exposed by the client and continuing until `has_more` is false. No finite depth is a complete-outline request. Use it as the structural map of the facet, and keep each row's `parent_id`, `depth`, `tokens` and `child_count`: categories 2, 7 and 8 depend on them. On a multilingual wiki the facet home is the target language's home (the wiki root for the primary language, the root's translation twin for another). State whether `pages_tree` is enabled in the report header. Tool names may be namespaced by the client; use the exposed Wikilayer tool whose final name matches the operation named here.
3. Spawn one general-purpose subagent per page, passing each the agreement signature from step 2 and requiring it on every call that binds it. Each subagent reads the page's **exact** content with `get_page_markdown(<page-id>)`, in reading order already. It runs the per-page categories below and returns a verdict in two parts.

   The first part is the findings: a proof-of-work line per clean block, and per finding a cited quote, the block URL, and what goes wrong if it is not applied. The second is a digest of the page, and it is what the wiki-level pass runs on: every substantive claim the page states, one line each, carrying its block id and the number, date, name or rule it asserts, followed by the subjects the page treats at length. Without the digest step 4 has nothing to collate. A contradiction between two pages lives in what each of them claims, and once the pages have been read in parallel nobody holds the claims of both.

   The fan-out is mechanics, not a division of the task. A whole wiki does not fit one context and an exact-text audit cannot run on a summary, so the pages are read at once and only their digests come back. Say this when reporting: the deliverable is one review of the whole body, and the per-page reads are how it was produced.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md` URL. WebFetch routes the page through a model that can silently reword or reorder content, which corrupts an exact-text audit (a block list was observed reordered this way). The tool returns the stored markdown untouched.

   Two things in that document are the engine's, not the author's: the `<!-- block:N -->` comment above each node, which is how a finding cites the node it belongs to, and the closing `## Links here` section after a `---` rule. Neither is ever a finding, and the rule before the section is not a heading smuggled into a body. Its absence is the evidence category 8 reads: a page whose document ends without one is a page nothing points at.
4. **(Wiki target only.)** Synthesize the wiki-level pass from the digests once every subagent has reported: cross-page contradictions, missed DRY, and structural grouping, all within the target facet. The caller does this; it is the only step that holds every page at once, and it is what a wiki target is bought for. Skip it and the run is a stack of page reviews, which is what the target was chosen not to be.

   Before reporting a contradiction, re-read the two blocks it names with `get_page_markdown`. A digest is a summary, and a summary can manufacture both an agreement and a conflict that the text does not hold.
5. Emit one markdown report, its findings ordered as the closing section says rather than grouped by the category that produced them. Caller never writes back to the wiki.

## Categories

Per-page (a subagent judges these from the page text):

1. **The outline against the page.** Read the titles alone first and stop there, because that is the whole map a reader has when deciding what to open. Say what you expect each node to hold. Only then read the bodies, and report every place the map was wrong.

   It goes wrong three ways, and each is reported as what it costs a reader:

   - a claim standing in a body that no title carries, so only someone who opened that body will ever learn it;
   - a title promising more than its body delivers, or promising something else, so a reader takes the wrong thing off the outline and has no reason to open it and find out;
   - two sibling titles you could not tell apart, so the outline stops being a map at that point.

   What a title is for depends on its level. At h2 the title names a section in a few words and never states the claim: the top level is read as a table of contents, and a sentence there competes with the page's own title. A single assertive h2 among ordinary ones is a finding on its own; a whole top level of them is a page written in one pass with no sections, and then say which sections its blocks fall into. From h3 down the title states the claim and the body argues it, so a title there that promises nothing keeps its claim off the outline.

   A page whose outline is only h2 is the same defect arriving the other way, and the one to check for before any of the above: the section names can each be correct and the page still put every claim it makes inside a body, where the outline shows none of them. Report that as one finding about the page rather than as one per buried claim, because the claims are not separately misplaced — the level below them is missing. Name the claims you found and say which sections they fall into.

   A node that groups children names a section at any depth. It is never a finding for promising nothing, and its body is optional: naming a section is the whole job, and the claims are in the children.

   The inverse is a heading over a single line: an outline row and a screenful of whitespace spent on what a bullet would say. Several siblings that each hold one line are one list, and so one finding, not one per heading; name the list they make. The sharpest case is a line that repeats the heading above it as a link to the page of the same name, where the title, the body and the navigation all say one word.

   Never recommend moving a node to another level so that its title fits, and never recommend widening a title until it restates its body. Depth follows the structure, and the title is written to fit the depth.
2. **Where a node sits.** The tree asserts something about every node by where it put it: that these are of one kind, that this one is the exception, that this follows from that. Read each claim against its parent and its siblings and say where the tree asserts something untrue.

   Apply page placement according to the wiki mode. With `pages_tree=true`, a page's page parent, siblings and child pages are authored structure and must be judged. With `pages_tree=false`, ordinary pages are deliberately flat: do not report the absence of a page parent or recommend one. Blocks still form a hierarchy inside their page in either mode.

   A heading that does not cover its children. A rule filed under a subject it does not belong to. A node nobody looking for it would look there for, which will be written a second time by whoever failed to find it. A node under a definition rather than under the thing defined.

   This is the category the rest of the report is worth the least without, and it is the one an agent skips, because it cannot be seen in any single body: it needs the parent read, the siblings read, and a guess at who came looking. Name the reader you have in mind when you report one.
3. **What the engine already keeps.** Every node carries its own history, its own `updated_at`, its place in the contents rail and the list of nodes linking to it, so a body repeating any of that goes stale the moment someone edits without touching it. Flag a block documenting its own obsolescence, a "checked in April" stamp, prose listing the sections below, a "back to X" footer.

   A count is the sharpest form of the same fault, because nobody edits a sentence to fix arithmetic: "four page types", "seven languages carry it", where those items are the blocks beneath. The test is where the sentence gets its truth from. From the tree of this page, and it goes; from the subject, the platform or the rule itself, it stays, even where its number happens to match the tree today. A founding year is content, a review date is metadata.

   A block that is mostly a hand-curated list of links is the same fault as an object rather than a sentence: "Contents", "See also", "Quick links". Strip the links and read what is left; if the block becomes nothing, it was navigation. Recommend deletion only after checking the one exception, and recommend deleting a tombstone only after confirming the content it names is live at the destination.

   The exception is what the navigation actually shows, and it shows less than the tree holds. With `pages_tree=false` there is none: nothing in the chrome lists ordinary pages, so a link in a body may be a page's only way in; never recommend cutting that link. With `pages_tree=true` the navigation opens collapsed to the top level, an inner page expands only the path to the root, and on a phone it sits behind the menu button. So a body link to a page below the top level is, for most readers, the only visible way there, and it is not a copy of the navigation. What the tree does settle is reachability: a page reached through its ancestor chain does not need an invented body link merely to exist in the map.

   The home page (`special_role=home`) is judged as a home page, never as an ordinary page of links. It is where a reader arrives without context, so it says what the wiki holds and links directly to the pages readers come for most, even where they sit deep in the tree; a list of such links is its content. Report a home page that does not name those pages, for instance one that links only the top-level sections they hide under, and report a subject it names twice. In either mode, flag a facet whose entry page gives the reader no path into its content.
4. **Two places saying one thing.** Not wordiness inside a block, which is lint's, but the same claim carried twice: by a block and its sibling, by a body and the title above it, by a page and the one it was split from. Today it is a repetition; tomorrow one of the two is edited and it is a contradiction, and nobody will know which copy is current.

Wiki-level (the caller synthesizes these from the digests and its own outline read):

5. **Contradictions across pages.** The same number, date, name, or fact stated differently in two places. This outranks everything else in the report: a reader acts on whichever they met first and never learns the other existed. For fiction or mystifications: the wiki should be internally consistent even when it is consistently making things up. Compare only within the language facet; a fact that reads differently in a page and its translation twin is a translation matter for `wikilayer:translations`, not a contradiction here.
6. **Missed DRY.** A subject treated substantively in several places with no dedicated root page of its own; recommend extracting. Count mentions within the facet only: a page's translation twin is the same mention in another language, not an additional one.
7. **A kinship the tree does not assert.** This page-level check runs only when `pages_tree=true`. Among the direct child pages of a page, two or more may belong to one subtopic with no page saying so. The tree currently asserts that they are siblings of everything else beside them, which is the false part; name the unasserted kinship and what a reader loses. Look at sibling title clusters. In a flat wiki, do not turn a thematic cluster into a missing-parent finding: page nesting is disabled by design.
8. **The page as one reading.** The caller has the outline, so it judges this: past a couple of dozen rows, or a few screens of body, a reader scrolls rather than reads and the contents rail stops being a map. Neither is a limit and neither decides on its own — a data page of a hundred parallel rows is not the target, and a page carrying several subjects that each stand alone is one at half that size.

   The test is whether a section could be opened cold. One that could is a page wearing a heading; sections that only make sense in sequence mean the page is long but whole, and the repair is to cut rather than to split. Report the weight of each top-level section beside the page total, because a section several times heavier than its siblings is the sharper signal: it is either a subject of its own or a topic whose parts never became child nodes, and saying which of the two it is is the finding.

   Price the split before recommending it: a promoted section stops being met by anyone scrolling its old parent and lives only through a link somebody writes into a body. Say where that link belongs.

   Reachability follows the wiki mode. With `pages_tree=false`, a page whose stitched document ends without a `## Links here` section is one nothing in this facet points at; flag it unless it is the facet home. With `pages_tree=true`, an ancestor chain in the page tree is an inbound route even when the stitched document has no backlinks; flag only pages absent from both hierarchy navigation and authored links.

## What a finding must carry

Two things, and a candidate missing either is not a finding.

A citation: the block URL plus the quote, or the list of titles, that demonstrates it. A subagent verdict of "looks fine" without proof-of-work is not acceptable; re-spawn that page if the verdict is thin.

And what goes wrong if it is not applied, said concretely: what becomes false, or what a reader does that they would not have done. "This reads better the other way" is not that. The requirement is what keeps this skill from returning a list of rewordings, which is the failure it is most prone to.

**Report a structural finding as what you read, not as the edit to make.** Renaming, splitting, merging and promoting are the author's calls: they are cheap to apply and expensive to judge, which is the combination that gets a wrong one applied without being weighed. So say what the outline showed you, what the body turned out to hold, and what a reader loses — and stop there. Naming where a node would sit better is part of the observation; handing over a finished title, a split, or a merge to paste in is not, and a finding phrased that way is one the author will apply instead of deciding.

## Order, and what the report is

Report in this order, because it is the order the work is done in, and every category above lands in one of its four steps:

1. a contradiction: two places say different things and a reader acts on whichever they met first;
2. a node where nobody will look for it, or a kinship the tree fails to assert: it will be written a second time by someone who did not find it;
3. a repetition, a body restating what the engine keeps, a page past one reading: each goes wrong on its own, without anybody touching it;
4. everything else this skill found.

The report is observations, not a verdict. Which to act on is the author's call, and a finding refused with a stated reason is as closed as one applied; say this in the report rather than phrasing findings as instructions. What the author must not do is take the cheap end of the list because it is cheap and leave the top of it for later.

Run again after the author has acted: the page is a different page now, and the arrangement they changed may have moved something else. The round ends when nothing left in the report changes what the wiki asserts.
