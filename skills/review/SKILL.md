---
description: Reader-perspective review of a wikilayer wiki — does the whole hang together as one coherent body of work? Checks structural coherence across pages, contradictions, missed DRY, and reading rhythm. Macro-level only — leaves the micro detail-hunt to /wikilayer:lint. Advisory only; never edits. Expensive, run before major releases or quarterly. Use when the user asks to review a wiki, audit it as a reader, or check it for coherence.
---

# wikilayer:review

Advisory reader-perspective audit. Where lint hunts micro antipatterns, review checks that the whole is coherent, consistent, and non-contradictory. Recommendations only — do not edit.

## Procedure

1. Resolve target wiki from `$ARGUMENTS`. If empty, ask.
2. `get_outline(<wiki-id>, max_depth=10)` once. Use it as the structural map.
3. Spawn one general-purpose subagent per page. Each subagent reads the page's **exact** content through the wikilayer MCP — `get_outline(<page-id>, max_depth=10, include_markdown=true)` — and sorts each node's children by their `sort_key` for reader order. It runs the per-page categories below and returns a compact verdict — proof-of-work line per clean block, full evidence (cited quote + block URL) per finding.

   Read the verbatim source, never a paraphrase: do **not** WebFetch the page or its `.md`. WebFetch routes the page through a model that can silently reword or reorder content, which corrupts an exact-text audit (a block list was observed reordered this way). `get_outline` returns the raw stored markdown with no engine decoration, so there is nothing to strip.
4. Synthesize the wiki-level pass once subagent verdicts are in: cross-page contradictions, missed DRY across the whole tree, structural grouping. The caller does this — it is the only step that needs every page's verdict at once.
5. Emit one markdown report grouped by category. Caller never writes back to the wiki.

## Categories

Per-page (subagent judges):

1. **Headings as a coherent table of contents.** Read block titles of the page in order, as if they were a chapter list. Do they together tell a connected story? Pure outline-level read, not body-deep. Adequate titles are the primary structure on this wiki; if the chapter list reads as a story, no opening hook is needed.
2. **Reading rhythm within each block.** Subagent reads each block as prose, not as a checklist. Even when the block isn't mechanically a wall (lint catches that), does it lose the thread mid-way? Topic jumps, missing connective tissue, paragraphs that don't continue the previous one — flag.

Wiki-level (caller synthesizes):

3. **Contradictions across pages.** The same number, date, name, or fact stated differently in two places. For fiction or mystifications: the wiki should be internally consistent even when it is consistently making things up.
4. **Missed DRY.** A subject mentioned substantively in three or more places, with no dedicated root page — recommend extracting.
5. **Sibling-blocks asking for a common parent.** Among the direct children of a page, two or more share an evident subtopic and would read better re-parented under a new intermediate block. Look at sibling title clusters.

## Evidence requirement

Every finding carries a citation: block URL plus the specific quote or title list that demonstrates the issue. A subagent verdict of "looks fine" without proof-of-work is not acceptable — re-spawn that page if the verdict is thin.

## Severity

- **High** — contradictions; broken structural coherence (titles that don't add up to a chapter list).
- **Medium** — missed DRY; sibling-grouping opportunities.
- **Low** — rhythm hiccups; phrasing judgment calls.
