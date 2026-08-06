---
description: Lint a wikilayer wiki, or one page in it, against the house style. Advisory only, reporting antipatterns with one-line recommendations, never editing. A page target is the focused pass right after editing that page; a wiki target is the full audit. Pair with /wikilayer:review when the reader-perspective pass also matters. Use when the user asks to lint a wiki or a single page, run the style checks, or audit before publishing.
---

# wikilayer:lint

Advisory style audit. Read each block, apply the check list, emit a markdown report grouped by page. Do not apply fixes.

The checks below mirror the house-style anti-patterns at https://wikilayer.org/smee-again/wikilayer-howto/3038-anti-patterns, the primary source. They are duplicated here on purpose: the skill must run self-contained against any wikilayer instance, including a localhost one with no authoring guide present, so it never fetches rules at lint time. When that page gains or changes a rule, mirror it here.

## Procedure

The caller never reads page bodies. Bodies live inside subagents; the caller only sees compact verdicts.

1. Resolve the target from `$ARGUMENTS` (numeric id or URL). If empty, ask.

   **Scope: whole wiki or one page.** The target may be a whole wiki or a single page (its subtree). Read its `kind` with `get_outline` or `get_node`. A `wiki` target lints every page in the facet; a `page` target lints that one. Every check runs per page either way. Use a page target for a focused pass after editing one page; a wiki target for a full audit.

   **Pick the language facet.** `get_outline` rows carry a `language` field. If the wiki is monolingual, the whole wiki is the facet and the rest runs unchanged. If it is multilingual, lint one language at a time: take the target language from `$ARGUMENTS` (for example `wiki 1 in en`), otherwise default to the wiki's primary language. Every check below runs on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page target is already one language. A page's translation twin in another language is not a duplicate; checking a translation against its source is the job of `wikilayer:translations`.
2. `get_outline(<wiki-id>, max_depth=10)` once. Use `tokens` and `child_count` on each row as first-pass signals to budget per-page work, and the `language` field to keep to the facet.
3. Spawn one general-purpose subagent per page. Each subagent reads its page's **exact** content with `get_page_markdown(<page-id>, limit=100, offset=0)`, paging with `offset` while `has_more` is true, runs the checks below, and returns a compact verdict: proof-of-work line per clean node, full finding with cited quote per violation. The page body never enters the caller context.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md` URL. WebFetch routes the page through a model that can reword or reorder it, which is fatal for micro checks like em-dash use or wall-of-text, which only mean anything against the exact bytes. The tool returns the stored markdown untouched.

   Two things in that document come from the engine, not the author, and are never findings: the `<!-- block:N -->` comment above each node, which is how a finding cites the node it belongs to, and the closing `## Links here` section after a `---` rule. The section is generated navigation and so is exempt from the invented-navigation check, which targets hand-written link lists inside a block body.
4. Caller aggregates per-page verdicts into one markdown report, grouped by page. Caller never writes back to the wiki.

## Checks

Each is a "smart prompt": the signal flags a candidate, the agent judges whether it's a real issue in context.

1. **Em-dash.** The em-dash (`—`) is a rare mark, earned, not default punctuation. Flag every occurrence and judge whether it is the seldom case where nothing else carries the meaning; almost always a comma, colon, period, or parentheses is the fix. Do not wave `—` through as "one per page is fine".
2. **Wall block.** Signal: a long body under a heading with no deeper heading beneath it. If it's two or more topical beats glued together, recommend decomposing into child blocks. If the body contains `**Bold.**` paragraph-leading bolds or `---` horizontal rules of its own, those are pseudo-headings smuggled into one body; recommend extracting them as real child blocks. The `---` that precedes the closing `## Links here` belongs to the engine and is not one of them.
3. **Opaque title.** Read the headings alone, as a reader scanning the outline does. If a title doesn't convey what the block or page is about ("Overview", "Contents", "Topic 1") or two siblings share a title with no differentiator, flag. The fix is rename, not delete; sometimes "Overview" is fine in context.

   When a title covers less than its body holds, say so, but do not prescribe widening the title as the fix. There are two repairs and the wrong one is easier: splitting the body so each part gets a title that fits, or narrowing what the title promises. Widening a title until it restates the whole body empties the body and produces rule 9.
4. **Invented navigation.** A block whose body is mostly a hand-curated list of links to other pages/blocks ("Contents", "See also", "Quick links", "Back to X"). The engine already generates per-page TOC and backlinks. Strip-links test: imagine the page printed on paper with no clickable links. If the block becomes garbage, it was navigation; recommend deletion. Apply the same test to individual prose links: `Click [here](...)` and `See [Foo](...), [Bar](...)` both fail without their links; an inline `[tenge](page:6564) was introduced in 1993` reads fine without the link. A link to a **different** page is not automatically fine: `see [Other Page]` or `detailed in [Other Page]` fails the strip-links test exactly like `see above`. A cross-page link earns its place only when the sentence still states its point without the link, with the page or block name reading as a noun in the sentence, not as a bare pointer.
5. **Same-page links.** Links from a block to another block or anchor on the same page. The reader is already scrolling this document. Cross-block jumps within a page are rare exceptions; flag and judge whether the link earns its keep.
6. **Block bloated into page material.** Signal: a body dramatically longer than its siblings at the same heading level, or a heading with no children carrying substantial content on a self-contained subject. Two escalations: if the content belongs to the current topic, recommend decomposing into child blocks (rule 2). If the subject is a self-standing entity that recurs elsewhere in the wiki, recommend extracting it to a dedicated root page.
7. **Tombstone block.** A block that documents its own obsolescence instead of being deleted: bodies reading "moved to…", "superseded", "stray block created by mistake", "deprecated", "safe to delete", often pointing at where the content "now lives". The wiki is versioned, so a dead block is removed, not left as a note. Recommend deletion once any live content it names is confirmed at the destination. These park on visible pages, frequently the home, and interrupt the read.
8. **Editorial date stamp.** A date in the body recording when the page was written, checked, or updated rather than something about the subject: "[Checked 2026-04-05]", "Updated April 2026", "as of Q2 …", "last reviewed …". The node's own `updated_at` already carries this, so the stamp only goes stale and misreports freshness. Recommend cutting it; keep dates that belong to the subject ("founded in 1863", "the 2008 reform"). Judge authorship-versus-subject per occurrence.

9. **Block thinner than its own title.** Signal: a heading with no children whose body is barely longer than the heading itself. If the body says no more than the title already said, the block should not exist: recommend folding the fact into a neighbouring block as a sentence or a bullet. The test is to cover the title and read the body alone; if it reads as a footnote to its own heading, merge it. A rendered heading above a single sentence looks like a defect rather than structure, and it costs an outline row as well as the whitespace. This is the mirror of rule 6: that one catches a node too big for its level, this one a node too small to be a node at all. Judge a deliberately terse definition list on its merits; the target is the block that restates its heading in smaller type.

10. **Orphan page.** The document ends without a `## Links here` section, meaning nothing in this facet points at the page: it is reachable only through the auto-generated side nav, not from any narrative. Flag, unless it is the facet home, which by definition has nothing above it. The section already answers this: the engine keeps a link table, scopes it to the page's own language, and counts the home among the sources, so a page the home introduces is not an orphan and says so. Common cause: a useful page nobody wove into the thread that starts at the home.

## Severity

- **Critical**: antipattern breaks the read or hides the page from readers (invented navigation, walls, orphan pages, tombstone blocks).
- **Warning**: style violation that survives but degrades (em-dash, opaque titles, editorial date stamps, blocks thinner than their titles).
- **Info**: judgment calls worth a look (same-page links, escalation candidates).
