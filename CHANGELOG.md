# Changelog

## 0.14.0
- lint: add **List that outgrew the name above it**. A block whose list has reached a dozen short links had no check against it: the wall and oversized-bullet checks both measure how long an item runs, and every item here is one line. What breaks is the outline, where one row now stands for two subjects and the items that arrived last are the ones nobody looks for under that name. Mirrors the guide's new anti-pattern.

## 0.13.0
- package the existing lint, review, and translations workflows as a Codex plugin without forking their instructions
- make skill invocation and target resolution portable between Claude Code and Codex
- follow the current Wikilayer MCP rules handshake and paged outline contract
- publish `info@wikilayer.org` as the plugin contact

## 0.12.2
- lint: the page-size check priced a split in rows added to a wiki root index, and there is no such index: the page chrome carries breadcrumbs, backlinks and the current page's own contents, and nothing that lists pages. The cost of promoting a section is that nobody meets it by scrolling its old parent any more, and it lives only through a link somebody writes. Two other checks already said the chrome lists nothing; this one disagreed with them.

## 0.12.1
- lint: stop prescribing a number of sections. The check told an author to name three to five of them, which is a limit the authoring guide never meant to set: a page has as many sections as its subject has parts, and the requirement is that each name is short and thematic rather than a claim. Mirrors the guide's own wording, which lost the count too.

## 0.12.0
- review: the wiki-level pass had nothing to run on. Subagents returned findings and proof-of-work, never the claims their page makes, so once the pages were read in parallel nobody held the claims of two pages at once and cross-page contradictions could not be found — only skipped or invented. Each per-page verdict now carries a digest as well: every substantive claim with its block id and the number, date, name or rule it asserts, plus the subjects the page treats at length. The caller collates the digests and re-reads the two blocks a contradiction names before reporting it, because a summary can manufacture both an agreement and a conflict.
- review: say that the fan-out is mechanics rather than a division of the task, and that the deliverable is one review of the whole body. A wiki target that skips the synthesis is a stack of page reviews, which is what the target was chosen not to be.

## 0.11.0
- lint: there is no side navigation, and two checks reasoned from one. **Outline narrated in prose** told an author that a panel already showed the pages their sentence named, and **Orphan page** called an unlinked page merely undiscoverable in the narrative. A page renders breadcrumbs that climb to the wiki and a contents rail holding its own blocks, nothing more, so a link in a body is the only path to a child page and an unlinked page has no way in at all.
- lint: **Invented navigation** no longer recommends deleting a page's only inbound link. A body whose links are what carry a reader into the wiki's pages is judged on whether it orients the reader, not by the strip-links test.

## 0.10.0
- lint, review: judge a title by its level. An h2 names a section and is set almost as large as the page title, so a claim written there competes with it; a claim belongs at h3 or deeper, where the heading states it and the body argues it. Both skills now flag a sentence-shaped h2, and flag a page whose entire top level is sentences as what it is: a page written in one pass with no sections. Neither ever recommends moving a block to another level to fit its title.

## 0.9.0
- lint, review: a framing title over a framing body is no longer a finding. Titles exist so that reading the outline alone is a map of what the wiki holds, and "Intro" over the paragraph saying what a page is and who it is for is a true entry on that map. What both checks flag now is the gap between promise and content: one statable idea under a heading that promises nothing, so the claim never reaches the map.

## 0.8.0
- lint: add **Page grown past one reading** — the first check that judges the page rather than its blocks. Sums the subtree and counts the outline, reports the weight of each top-level section so an imbalance shows, and tests whether a section could be opened cold. Names the cost of the fix too: pages parent under the wiki and nowhere else, so promoting sections lengthens the root index.

## 0.7.0
- lint: add **Outline narrated in prose** — a body that lists the sections under it, or counts them, duplicates what the engine already renders and drifts the moment a child is added or renamed. The check turns on where the sentence gets its truth from: the tree of this page, or the subject. A count the tree already contradicts is Critical rather than Warning, since the reader can see it is wrong.

## 0.6.0
- review, translations: read each page with `get_page_markdown`, the same one-call document lint moved to in 0.5.0.
- translations: a twin's `## Links here` section is not compared. Each language has its own inbound links, so a twin with a different list, or none, is not a structural divergence and never a reason to write.

## 0.5.0
- lint: reads each page with `get_page_markdown`, one call returning the page as one document, instead of an outline carrying every body. Findings cite the node through the `<!-- block:N -->` comment the document puts over each one.
- lint: **Orphan page** no longer costs a `search_nodes` call per page. The document closes with the pages that link to it, so an absent section is the answer. Needs wikilayer 0.60.0 or newer, where that section counts the wiki home among the sources and keeps to one language.
- lint: the wiki-level phase is gone with it. Every check now runs inside the per-page subagent, and the procedure is one step shorter.

## 0.4.0
- lint: add **Block thinner than its own title** — a leaf whose body says no more than its heading already said should be folded into a neighbour, not kept as a node. A rendered heading above a single sentence reads as a defect, and it costs an outline row on top of the whitespace.
- lint: the **Opaque title** check no longer implies that widening the title is the fix. A title narrower than its body has two repairs, splitting the body or narrowing the promise, and reaching for the third one empties the body and produces the new check above.

## 0.3.0
- lint: add two checks — **Tombstone block** (a block that documents its own obsolescence instead of being deleted) and **Editorial date stamp** (an authorship/freshness date the node's `updated_at` already records).
- lint: cite the public anti-patterns page as the primary source, and note the checklist is duplicated in the skill on purpose so it runs self-contained against any instance (including a localhost one with no authoring guide).

## 0.2.0
- Marketplace install support (permanent install via `marketplace.json`); review frontmatter YAML fix.
