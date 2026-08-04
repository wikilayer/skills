# Changelog

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
