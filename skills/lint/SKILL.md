---
description: Lint a wikilayer wiki against the house style. Advisory only, reporting antipatterns with one-line recommendations, never editing. Pair with /wikilayer:review when the reader-perspective pass also matters. Use when the user asks to lint a wiki, run the style checks, or audit before publishing.
---

# wikilayer:lint

Advisory style audit. Read each block, apply the check list, emit a markdown report grouped by page. Do not apply fixes.

## Procedure

The caller never reads page bodies. Bodies live inside subagents; the caller only sees compact verdicts.

1. Resolve the target wiki from `$ARGUMENTS` (numeric id or URL). If empty, ask.

   **Pick the language facet.** `get_outline` rows carry a `language` field. If the wiki is monolingual, the whole wiki is the facet and the rest runs unchanged. If it is multilingual, lint one language at a time: take the target language from `$ARGUMENTS` (for example `wiki 1 in en`), otherwise default to the wiki's primary language. Every check below runs on the **target-language facet** only, the nodes whose effective language is the target (an empty `language` inherits the primary). State the facet in the report header. A page's translation twin in another language is not a duplicate; checking a translation against its source is the job of `wikilayer:translations`.
2. `get_outline(<wiki-id>, max_depth=10)` once. Use `tokens` and `child_count` on each row as first-pass signals to budget per-page work, and the `language` field to keep to the facet.
3. Spawn one general-purpose subagent per page. Each subagent reads its page's **exact** content through the wikilayer MCP (`get_outline(<page-id>, max_depth=10, include_markdown=true)`, sorting each node's children by `sort_key` for reader order), runs the per-block checks below, and returns a compact verdict: proof-of-work line per clean block, full finding with cited quote per violation. The page body never enters the caller context.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md`. WebFetch routes the page through a model that can reword or reorder it, which is fatal for micro checks like em-dash use or wall-of-text, which only mean anything against the exact bytes. `get_outline` returns the raw stored markdown with no engine decoration to mistake for an antipattern.
4. Caller runs the wiki-level graph checks (rule 7 below) using `get_outline(<wiki-id>, body_contains=<pattern>)` queries; no body content needed, the outline tells the story.
5. Caller aggregates per-page verdicts + wiki-level findings into one markdown report, grouped by page (per-block) and by category (graph). Caller never writes back to the wiki.

## Per-block checks

Each is a "smart prompt": the signal flags a candidate, the agent judges whether it's a real issue in context.

1. **Em-dash overuse.** While reading prose, watch for `—` clustering or replacing a comma that would clearly do. One per page is fine. Multiple per paragraph is not. Judge per occurrence.
2. **Wall block.** Signal from outline: `tokens` substantial AND `child_count == 0`. Read body. If it's two or more topical beats glued together, recommend decomposing into child blocks. If body contains `**Bold.**` paragraph-leading bolds, `---` horizontal rules, or `# ` markdown headers: those are pseudo-headings smuggled into one body. Recommend extracting them as real child blocks.
3. **Opaque title.** Walk outline as a reader who only sees titles. If a title doesn't convey what the block/page is about ("Overview", "Contents", "Topic 1") or two siblings share a title with no differentiator, flag. The fix is rename, not delete; sometimes "Overview" is fine in context.
4. **Invented navigation.** A block whose body is mostly a hand-curated list of links to other pages/blocks ("Contents", "See also", "Quick links", "Back to X"). The engine already generates per-page TOC and backlinks. Strip-links test: imagine the page printed on paper with no clickable links. If the block becomes garbage, it was navigation; recommend deletion. Apply the same test to individual prose links: `Click [here](...)` and `See [Foo](...), [Bar](...)` both fail without their links; an inline `[tenge](page:6564) was introduced in 1993` reads fine without the link.
5. **Same-page links.** Links from a block to another block or anchor on the same page. The reader is already scrolling this document. Cross-block jumps within a page are rare exceptions; flag and judge whether the link earns its keep.
6. **Block bloated into page material.** Signal from outline: a block whose `tokens` are dramatically larger than its siblings, or a leaf block carrying substantial content on a self-contained subject. Two escalations: if the content belongs to the current topic, recommend decomposing into child blocks (rule 2). If the subject is a self-standing entity that recurs elsewhere in the wiki, recommend extracting it to a dedicated root page.

## Wiki-level checks

Run by the caller after per-page verdicts are collected. Mechanical graph queries against `get_outline`, no body content needed.

7. **Orphan page.** For each page P with id N in the facet, call `get_outline(<wiki-id>, body_contains="(page:N)")` and keep only hits whose language is the facet's. If none remain (no facet block references `(page:N)`), P is reachable only via the auto-generated side nav, not from any narrative on another page. Flag, unless P is the facet home, which by definition has no incoming wiki links. A reference from another language facet does not weave P into this one, and P having a twin in another language does not count as being linked here. Common cause: a useful page that nobody wove into the narrative thread starting at the home.

## Severity

- **Critical**: antipattern breaks the read or hides the page from readers (invented navigation, walls, orphan pages).
- **Warning**: style violation that survives but degrades (em-dash overuse, opaque titles).
- **Info**: judgment calls worth a look (same-page links, escalation candidates).
