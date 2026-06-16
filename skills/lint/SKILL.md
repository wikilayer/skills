---
description: Lint a wikilayer wiki against the house style. Advisory only — reports antipatterns with one-line recommendations, never edits. Pair with /wikilayer:review when the reader-perspective pass also matters. Use when the user asks to lint a wiki, run the style checks, or audit before publishing.
---

# wikilayer:lint

Advisory style audit. Read each block, apply the check list, emit a markdown report grouped by page. Do not apply fixes.

## Procedure

1. Resolve target wiki from `$ARGUMENTS` (numeric id or URL). If empty, ask.
2. `get_outline(<wiki-id>, max_depth=10)` once. Use `tokens` and `child_count` on each row as first-pass signals.
3. Walk blocks in outline order. For each, decide if any check below trips. If yes, read the body and judge in context.
4. Emit one markdown report grouped by page, with severity tags and one-line fix suggestions.

## Checks

Each is a "smart prompt": the signal flags a candidate, the agent judges whether it's a real issue in context.

1. **Em-dash overuse.** While reading prose, watch for `—` clustering or replacing a comma that would clearly do. One per page is fine. Multiple per paragraph is not. Judge per occurrence.
2. **Wall block.** Signal from outline: `tokens` substantial AND `child_count == 0`. Read body. If it's two or more topical beats glued together, recommend decomposing into child blocks. If body contains `**Bold.**` paragraph-leading bolds, `---` horizontal rules, or `# ` markdown headers — those are pseudo-headings smuggled into one body. Recommend extracting them as real child blocks.
3. **Opaque title.** Walk outline as a reader who only sees titles. If a title doesn't convey what the block/page is about ("Overview", "Contents", "Topic 1") or two siblings share a title with no differentiator, flag. The fix is rename, not delete — sometimes "Overview" is fine in context.
4. **Invented navigation.** A block whose body is mostly a hand-curated list of links to other pages/blocks ("Contents", "See also", "Quick links", "Back to X"). The engine already generates per-page TOC and backlinks. Strip-links test: imagine the page printed on paper with no clickable links. If the block becomes garbage, it was navigation; recommend deletion. Apply the same test to individual prose links — `Click [here](...)` and `See [Foo](...), [Bar](...)` both fail without their links; an inline `[tenge](page:6564) was introduced in 1993` reads fine without the link.
5. **Same-page links.** Links from a block to another block or anchor on the same page. The reader is already scrolling this document. Cross-block jumps within a page are rare exceptions; flag and judge whether the link earns its keep.
6. **Block bloated into page material.** Signal from outline: a block whose `tokens` are dramatically larger than its siblings, or a leaf block carrying substantial content on a self-contained subject. Two escalations: if the content belongs to the current topic, recommend decomposing into child blocks (rule 2). If the subject is a self-standing entity that recurs elsewhere in the wiki, recommend extracting it to a dedicated root page.

## Severity

- **Critical** — antipattern breaks the read (invented navigation, walls).
- **Warning** — style violation that survives but degrades (em-dash overuse, opaque titles).
- **Info** — judgment calls worth a look (same-page links, escalation candidates).
