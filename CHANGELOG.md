# Changelog

## 0.21.0

### Fixed

- review: in a hierarchical wiki the skill treated the page tree as navigation every reader sees, so a home page listing the pages readers come for read as a restatement of the navigation to be cut. The navigation opens collapsed to the top level, expands only the path to the root on an inner page, and hides behind the menu button on a phone, so a body link below the top level is usually the only visible way there. The exception now follows what the navigation shows rather than what the tree holds.
- review: the home page is judged as a home page. It is reported when it does not name the pages readers come for, for instance by linking only the top-level sections that hide them, or when it names a subject twice.
- review: a heading over a single line had no check, so a top level of headings each followed by one line repeating the heading as a link passed clean. Such siblings are now reported as one finding, the list they should be. Mirrors the guide.

## 0.20.1

### Fixed

- review: narrow the skill description to whole-page coherence checks after recent edits, so a request to research a subject mentioned in a wiki does not trigger a full wiki audit.
- lint: make it the final polish pass after review and substantive edits, rather than an early style check.

## 0.20.0

### Fixed

- lint, review, translations: read the whole outline with `max_depth=-1`; the former depth of 10 was an arbitrary silent truncation presented as a complete map.
- lint, review, translations: resolve and report the wiki's `pages_tree` mode instead of inferring hierarchy from the current outline.
- review: judge page placement, missing grouping and reachability differently in flat and hierarchical wikis, and read a page target's immediate structural neighbourhood when hierarchy is enabled.
- translations: preserve page parents when hierarchy is enabled, keep pages flat when it is disabled, and create translated page trees by depth so a child is never scheduled before its translated parent exists.

## 0.19.1

### Fixed

- lint: its metadata is valid YAML again, so strict plugin validation accepts the skill. The lint workflow itself is unchanged.

## 0.19.0

### Removed

- translations: removed support for marking content `i18n-exempt`. When asked to bring a wiki or page into translation parity, the skill now translates every page and block that has no corresponding version in the target language, then links the new translation to its source. Before upgrading, remove the tag and all of its assignments from existing wikis; there is no replacement exemption mechanism.

## 0.18.1
- translations: the instruction to the translator said "no em-dash" with no exception, and this skill writes. Translating into a language that uses the mark as ordinary punctuation, or requires it, therefore put prose a native reader sees as wrong straight into the wiki, with no report anyone could refuse. Punctuation now follows the target language's own conventions rather than the source's.
- lint, translations, and the guide page they mirror: restraint with the em-dash was stated as a rule with a grammatical exception, and the exception named one language. That is two errors in one — the restraint is an English convention rather than a universal rule, and a language can use the mark as ordinary punctuation without being required to, which the exception did not cover. All three now say to judge by the conventions of the language in hand, and name German and Russian as examples rather than as the list.

## 0.18.0
- review: the skill checked form and called it structure. Its first category opened with seven paragraphs of surface signals — a `##` typed into a body, three or more bold lead-ins, a rule of the body's own, a list past ten items, a body several times longer than its siblings — and reached what the tree actually asserts in one closing sentence. An agent working the category top-down therefore spent the run counting markers and arrived at placement, the one thing only this skill can see, with nothing left. Marks, wording, voice and paragraph form are now refused outright as lint's, a typographic marker is demoted to the trace of a claim that never became a node rather than a finding of its own, and nothing in the skill is decided by counting.
- review: the first category is now a reading. Titles alone first, write down what each promises, then the bodies, and the finding is the place the map was wrong. Where a node sits is a category of its own rather than the last line of another, and it carries the note that it is the one an agent skips, because it cannot be seen in any single body.
- review: the h2 rule could be derived backwards. The prohibition on a claim at h2 survived only in the plural ("a top level written as sentences"), so a single assertive h2 passed, while the test for a title covering less than its body carried no depth scope and pushed toward making one. It now fires on one h2, the deeper tests are scoped to h3 and below, and the reason — that the top level is read as a table of contents and a sentence there competes with the page's own title — is stated where the rule is.
- review, lint: the guide's grouping-node exception, "a node that groups children names a section at any depth", was in neither skill. Every correctly named grouping node therefore read as a heading that promises nothing, which is a false finding on the shape the guide recommends. Restored, with its body declared optional.
- review: a page whose outline is only h2 had no check at all. The sections can each be correctly named and the page still hold every claim it makes inside a body, where the outline shows none of them; the skill reported that as one finding per buried claim, which reads as several small problems rather than one missing level. Now one finding about the page. Mirrors the guide, which had lost the same case.
- review: structural findings are returned as observations rather than as the edit to make. Renaming, splitting, merging and promoting are cheap to apply and expensive to judge, and that combination is what gets a wrong one applied without being weighed.
- lint: the em-dash check had no exception for languages whose grammar requires the mark, though the guide has carried one since the page was written. On a Russian wiki it flagged every dash standing in for an absent copula, which is spelling, so the check reported a finding on every page.
- lint, review: drop the thresholds the skills invented and the guide never states — three or more bold lead-ins, ten or more list items, three or more one-line paragraphs, 2,000 tokens, three or more mentions. Each made the skill disagree with its own source page, and each made it laxer: two bold lead-ins carrying two claims passed.

## 0.17.0
- lint, review: the two split by grain rather than by consequence, so one report could carry a contradiction and an em-dash as neighbours, and the cheap findings got done first because they were cheap while the expensive ones moved to "later". They now split by subject, lint reading the text and review the tree and the claims, which is the same line as whether a finding can become false: lint says in its own report that nothing it finds is worth a second pass, and review earns a second reading of the page. Nine of lint's structural checks moved to review and arrived as three categories, because a claim that never became a node, a title and a body that disagree, and a body restating what the engine already keeps were the three faults under them; page size and reachability moved too and stayed their own category, judged by the caller from the outline. Lint gained the two checks that were review's and never became false: a block that loses its thread, and words that say nothing.
- review: a finding had to carry a citation and nothing else, so a rewording could pass as one. It must now also say what becomes false, or what a reader does that they would not have done, and the report is ordered by that: a contradiction first, then a node where nobody will look for it, then what goes wrong on its own without anybody touching it, then the rest.
- review: the report read as a worklist, and an author who applied every line was doing what the skill appeared to ask. It now says that it returns observations, that a finding refused with a stated reason is as closed as one applied, and that the round ends when nothing left changes what the wiki asserts.
- lint, review, translations: all three named source pages in the authoring guide that no longer exist. The guide was rebuilt around its principles, and the anti-patterns and writing-style pages were dismantled into them; each skill now mirrors the page that replaced its own.
- the Codex manifest had drifted two versions behind the Claude one. Both carry the same version again.

## 0.16.0
- review: the skill said it reads for the house writing style and then carried no pointer to it, while lint has named its own source page since the start. The two now mirror the guide the same way, each from the page that belongs to it: the anti-patterns for lint, the writing style for review, both duplicated here so the skills run without the guide present.
- lint: drop the note about rules that belong to review. Now that a rule's page says which skill mirrors it, the note said the same thing a second time and would go stale on its own.

## 0.15.0
- review: nothing read the text for what it spends. A block could carry twice the words its claim needs and pass every category, and a long block gets skimmed, so the cost lands on every reader of it rather than once on its author. Review now writes the shorter version and quotes what goes: a verdict with no rewritten text is not a finding, a cut counts only when the shorter version is visibly shorter and still says everything the original said, and a block already as short as its claim allows earns a proof-of-work line, because this is the check most prone to inventing work. Mirrors the guide's new anti-pattern.
- review, lint: the two skills split by grain, "macro-level only" against "micro antipatterns", which left the wording of a block out of reach of both. Lint's checks are structural, and review disclaimed the sentence. They now split by kind: lint runs the fixed antipattern checklist over the tree, review is the editor's read, and lint's mirroring paragraph names the rule it cannot mirror.
- lint, review: the rules agreement signature never reached the subagents. The caller accepted the server's rules and then handed every protected read to a fan-out with no signature to carry, so each page read was refused on its first call.

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
