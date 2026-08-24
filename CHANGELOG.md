# Changelog

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
