---
name: review
description: "Review the coherence of a Wikilayer page, a list of pages or a whole wiki after recent edits, once you have read them whole yourself and fixed what you found: a check on finished work, not a way to finish it. Advisory only; never edits."
---

# wikilayer:review

Read the wiki as the person who came to it for something, and report what the arrangement told them. The arrangement of nodes is itself a claim: where a node sits says that these are of one kind, that this follows from that, that this is the exception. Recommendations only. Do not edit.

This skill reads as a reader; lint reads the text. Everything found here can become false, which is why a finding here earns a second reading of the page and a lint finding never does. Keep the two reports apart: merged into one list the cheap findings crowd out the expensive ones, and the cheap ones get done first because they are cheap.

**This skill does not check form.** Marks, the em-dash, wording, voice, the shape of a paragraph, a block that lost its thread or spends more words than its claim needs: all lint's, and reporting one here is a defect in the run. A typographic marker inside a body — a bold lead-in, a horizontal rule, a bullet that runs for paragraphs — is at most the trace of a claim that never became a node. The finding is the claim, quoted, and the fact that the outline does not show it; the marker is how you noticed, never what you report, and a count of markers is not a finding at all. Nothing here is decided by counting.

The categories below mirror https://wikilayer.org/smee-again/wikilayer-howto/54721-pages-and-nodes and the principles they come from at https://wikilayer.org/smee-again/wikilayer-howto/59315-writing-a-wiki, duplicated here so the skill runs self-contained against any wikilayer instance, including one with no authoring guide present. When either page gains or changes a rule, mirror it here.

## Procedure

One agent runs the whole review, and not the one that wrote the pages: the author reads what they meant. Before the run, the author reads every page the edit affects, whole, as a reader who does not know the author's intent, and fixes what that reading shows. Review is a check on finished work, not a way to finish it: a reviewer is for what the author cannot see from inside, and a slip visible on a first reading costs a review here. Many findings mean the caller skipped that reading, so the caller goes back to it rather than into another round. This mirrors https://wikilayer.org/smee-again/wikilayer-howto/54798-editing-a-wiki#block-54803.

1. Resolve the target from the user's request (numeric id, URL, or unambiguous wiki/page name). If it is missing or ambiguous, ask. Resolve its owning wiki with `list_wikis(wiki_ids=[...])`. Pages nest: a page sits under the wiki or under another page, and that page tree is the wiki's navigation. A wiki whose `list_wikis` row has `pages_tree=false` is in the old flat mode, where every ordinary page hangs from the wiki and nothing in the chrome lists pages; there, report no missing page parent or unasserted kinship, and treat a page without inbound links as unreachable.

   **Scope: whole wiki, one page, or a list of pages.** Read each target's `kind` with `get_outline` or `get_node`. A `wiki` target runs the full procedure; a `page` target reviews that page and its blocks, not descendant pages, and skips the wiki-level synthesis in step 4. A list of pages, all in one wiki, reviews each as a page target and then runs step 4 across the listed pages only. A page review still reads the target page's immediate page parent, page siblings and child-page titles as structural context for category 2; it does not review their bodies. Reach for a page target when one page was just added or reworked, a list when an edit touched several pages, and a wiki target for the periodic whole-body pass.

   **Pick the language facet.** `get_outline` rows carry a `language` field; collect the distinct languages present. If the wiki is monolingual, the whole wiki is the facet and the rest of this procedure runs unchanged. If it is multilingual, this skill audits one language at a time: take the target language from the user's request (for example `wiki 1 in en`), otherwise default to the wiki's primary language (the root's language). Every step below operates on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page target is already one language, so it needs no facet choice.

   A language twin is the same topic in another language, never a finding. A page and its translation are not a contradiction, not missed DRY, not a duplicate. Checking a translation against its source is the job of `wikilayer:translations`, not this skill, so nodes outside the target facet stay out of scope for this run.
2. Read and accept any rules the Wikilayer server requires before protected reads, then carry the returned agreement token on every call it binds. Read the wiki's own rules page whole (`get_page_markdown(wiki_id=<wiki-id>, special_role='rules')`), not only to sign it: a block there titled `wikilayer:review` is this wiki's checklist for this skill. Run its checks on every page in scope as further categories, cite the block in each finding they produce, and order those findings with the rest. They add to the categories below and never remove, soften or override one, nor this skill's boundary with lint; a checklist item about form is lint's and is left to it. A wiki without such a block adds nothing. This mirrors https://wikilayer.org/smee-again/wikilayer-howto/55269-wiki-rules#block-59952. Read the complete outline with `get_outline(<wiki-id>, max_depth=-1)`, supplying the pagination arguments exposed by the client and continuing until `has_more` is false. No finite depth is a complete-outline request. Use it as the structural map of the facet, and keep each row's `parent_id`, `depth`, `tokens` and `child_count`: categories 2, 7 and 8 depend on them. On a multilingual wiki the facet home is the target language's home (the wiki root for the primary language, the root's translation twin for another). Tool names may be namespaced by the client; use the exposed Wikilayer tool whose final name matches the operation named here.
3. Read every page in scope yourself with `get_page_markdown(<page-id>)`, which returns it whole and in reading order, and run the per-page categories below on it. Do not hand pages to other agents: the review exists for how the pages read together, and a reader who saw one page cannot see that.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md` URL. WebFetch routes the page through a model that can silently reword or reorder content, which corrupts an exact-text audit (a block list was observed reordered this way). The tool returns the stored markdown untouched.

   Two things in that document are the engine's, not the author's: the `<!-- block:N -->` comment above each node, which is how a finding cites the node it belongs to, and the closing `## Links here` section after a `---` rule. Neither is ever a finding, and the rule before the section is not a heading smuggled into a body. Its absence is the evidence category 8 reads: a page whose document ends without one is a page nothing points at.
4. **(Wiki or list target.)** Once every page in scope is read, run the wiki-level categories across them: contradictions, missed DRY and structural grouping, within the target facet, and for a list within the listed pages. Skip it and the run is a stack of page reviews, which is what the target was chosen not to be.

   Before reporting a contradiction, re-read the two blocks it names.
5. Emit one markdown report, its findings ordered as the closing section says rather than grouped by the category that produced them. Never write back to the wiki.

## Categories

Per-page (judged from each page's text):

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

   A page's page parent, siblings and child pages are authored structure and are judged the same way as blocks inside a page.

   A heading that does not cover its children. A rule filed under a subject it does not belong to. A node nobody looking for it would look there for, which will be written a second time by whoever failed to find it. A node under a definition rather than under the thing defined.

   This is the category the rest of the report is worth the least without, and it is the one an agent skips, because it cannot be seen in any single body: it needs the parent read, the siblings read, and a guess at who came looking. Name the reader you have in mind when you report one.
3. **What the engine already keeps.** Every node carries its own history, its own `updated_at`, its place in the contents rail and the list of nodes linking to it, so a body repeating any of that goes stale the moment someone edits without touching it. Flag a block documenting its own obsolescence, a "checked in April" stamp, prose listing the sections below, a "back to X" footer.

   A count is the sharpest form of the same fault, because nobody edits a sentence to fix arithmetic: "four page types", "seven languages carry it", where those items are the blocks beneath. The test is where the sentence gets its truth from. From the tree of this page, and it goes; from the subject, the platform or the rule itself, it stays, even where its number happens to match the tree today. A founding year is content, a review date is metadata.

   A block that is mostly a hand-curated list of links is the same fault as an object rather than a sentence: "Contents", "See also", "Quick links". Strip the links and read what is left; if the block becomes nothing, it was navigation. Recommend deletion only after checking the one exception, and recommend deleting a tombstone only after confirming the content it names is live at the destination.

   The exception is what the navigation actually shows, and it shows less than the tree holds: it opens collapsed to the top level, an inner page expands only the path to the root, and on a phone it sits behind the menu button. So a body link to a page below the top level is, for most readers, the only visible way there, and it is not a copy of the navigation. What the tree does settle is reachability: a page reached through its ancestor chain does not need an invented body link merely to exist in the map.

   The home page (`special_role=home`) and every page with child pages are judged by featured navigation, never as ordinary pages of links. They open with what is worth reading below and link a few pages readers come for, even deep ones; those links are their content. Report one that copies the tree by listing its children, one that links only the top-level sections the wanted pages hide under, and a subject it names twice. A full list of children is right only when the reader must choose among all of them, as with ways to install. Flag a facet whose entry page gives the reader no path into its content.
4. **Two places saying one thing.** Not wordiness inside a block, which is lint's, but the same claim carried twice: by a block and its sibling, by a body and the title above it, by a page and the one it was split from. Today it is a repetition; tomorrow one of the two is edited and it is a contradiction, and nobody will know which copy is current.

Wiki-level (judged across the pages in scope, with the outline):

5. **Contradictions across pages.** The same number, date, name, or fact stated differently in two places. This outranks everything else in the report: a reader acts on whichever they met first and never learns the other existed. For fiction or mystifications: the wiki should be internally consistent even when it is consistently making things up. Compare only within the language facet; a fact that reads differently in a page and its translation twin is a translation matter for `wikilayer:translations`, not a contradiction here.
6. **Missed DRY.** A subject treated substantively in several places with no dedicated root page of its own; recommend extracting. Count mentions within the facet only: a page's translation twin is the same mention in another language, not an additional one.
7. **A kinship the tree does not assert.** Among the direct child pages of a page, two or more may belong to one subtopic with no page saying so. The tree currently asserts that they are siblings of everything else beside them, which is the false part; name the unasserted kinship and what a reader loses. Look at sibling title clusters.
8. **The page as one reading.** Judged from the outline: past a couple of dozen rows, or a few screens of body, a reader scrolls rather than reads and the contents rail stops being a map. Neither is a limit and neither decides on its own — a data page of a hundred parallel rows is not the target, and a page carrying several subjects that each stand alone is one at half that size.

   The test is whether a section could be opened cold. One that could is a page wearing a heading; sections that only make sense in sequence mean the page is long but whole, and the repair is to cut rather than to split. Report the weight of each top-level section beside the page total, because a section several times heavier than its siblings is the sharper signal: it is either a subject of its own or a topic whose parts never became child nodes, and saying which of the two it is is the finding.

   Price the split before recommending it: a promoted section stops being met by anyone scrolling its old parent and lives only through a link somebody writes into a body. Say where that link belongs.

   An ancestor chain in the page tree is an inbound route even when the stitched document has no backlinks; flag only pages absent from both the navigation and authored links.

## What a finding must carry

Two things, and a candidate missing either is not a finding.

A citation: the block URL plus the quote, or the list of titles, that demonstrates it. A page reported clean carries a proof-of-work line per block; "looks fine" is not one.

And what goes wrong if it is not applied, said concretely: what becomes false, or what a reader does that they would not have done. "This reads better the other way" is not that. The requirement is what keeps this skill from returning a list of rewordings, which is the failure it is most prone to.

**Report a structural finding as what you read, not as the edit to make.** Renaming, splitting, merging and promoting are the author's calls: they are cheap to apply and expensive to judge, which is the combination that gets a wrong one applied without being weighed. So say what the outline showed you, what the body turned out to hold, and what a reader loses — and stop there. Naming where a node would sit better is part of the observation; handing over a finished title, a split, or a merge to paste in is not, and a finding phrased that way is one the author will apply instead of deciding.

## Order, and what the report is

Report in this order, because it is the order the work is done in, and every category above lands in one of its four steps:

1. a contradiction: two places say different things and a reader acts on whichever they met first;
2. a node where nobody will look for it, or a kinship the tree fails to assert: it will be written a second time by someone who did not find it;
3. a repetition, a body restating what the engine keeps, a page past one reading: each goes wrong on its own, without anybody touching it;
4. everything else this skill found.

The report is observations, not a verdict. Which to act on is the author's call, and a finding refused with a stated reason is as closed as one applied; say this in the report rather than phrasing findings as instructions. What the author must not do is take the cheap end of the list because it is cheap and leave the top of it for later.
