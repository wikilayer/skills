---
name: translations
description: Bring a wikilayer wiki, or one page in it, into translation parity with a target language. Audits cross-language coverage (missing translations, structural divergence, stale or orphan nodes), then translates and links the gaps. A page target fills only that page's subtree, for a page just added or reworked. Unlike the wikilayer lint and review skills this skill writes to the wiki. Use when the user asks to translate a wiki or a single page, fill its missing translations, or check translation parity.
---

# wikilayer:translations

Parity pass across languages. lint and review only advise; this skill also writes: it creates and links the translations a wiki is missing in a target language. It audits first, fills the gaps, and reports the judgment calls (structural divergence, staleness) for a human rather than forcing them.

## Model

Translations live as parallel nodes in the same wiki, grouped by `link_translation`: a topic has one node per language, all in one group. A wiki's `primary_language` is the source; source nodes carry that language or an empty `language` field. A target-language node is a translation linked into the same group.

A source node is a **gap** when no node in its translation group carries the target language. Filling a gap means translating the source node, creating the target node with `language` set, and linking the two.

## Procedure

The caller never holds page bodies. Bodies live inside subagents; the caller sees compact reports.

1. Resolve the target and target language from the user's request (for example "wiki 1 to en", or a URL plus a BCP 47 code). Resolve the wiki with `list_wikis(wiki_ids=[...])`, record its `primary_language` and `pages_tree`, and never infer either from the current outline shape. The primary language is the source. If the target or target language is unclear, ask.

   **Scope: whole wiki or one page.** The target may be a whole wiki or a single page (its subtree). A `wiki` target brings the whole wiki to parity; a `page` target fills gaps only within that page's subtree, for example a page just added or reworked that you want translated now. The source language and the structural map still come from the wiki, but step 4 only spawns over source pages inside the scope.
2. Read and accept every rules page the Wikilayer server requires before protected reads or writes, then carry the returned agreement tokens on every call they bind. A translation is a write like any other, so it answers to [what a node holds](https://wikilayer.org/smee-again/wikilayer-howto/54721-what-a-node-holds) and to [wording and marks](https://wikilayer.org/smee-again/wikilayer-howto/54729-wording-and-marks).
3. Read the complete outline with `get_outline(<wiki-id>, max_depth=-1)`, supplying the pagination arguments exposed by the client and continuing until `has_more` is false. No finite depth is a complete-outline request. Each row carries `language` (omitted when empty), `parent_id` and `depth`. This is the structural map: source-language pages, existing target-language pages, and their nesting. Tool names may be namespaced by the client; use the exposed Wikilayer tool whose final name matches the operation named here.
4. Schedule one general-purpose subagent per source page in scope (the whole wiki, or just the target page's page subtree; skip pages whose whole subtree is already linked).

   With `pages_tree=false`, source pages are flat peers and their page jobs may run in parallel. With `pages_tree=true`, process page jobs by page depth: all missing target pages at one depth may run in parallel, but no child-page job starts until the target-language twin of its source page parent exists. Blocks inside a page keep their own source order and nesting. This dependency is correctness, not an optimisation: creating every page concurrently can orphan a translation or put it under the wrong parent.

   A page-scoped request does not silently widen itself to translate missing ancestors. If a hierarchical source page needs a target-language parent twin that does not exist and lies outside the requested subtree, report that prerequisite and stop before creating the page. Never fall back to the wiki root or to another convenient parent.

   Each subagent:
   - Reads the source page's **exact** content with `get_page_markdown(<page-id>)`. Read the verbatim source, never WebFetch the `.md` URL, which a model can reword. The `<!-- block:N -->` comment above each node is the id to link a translation to; the closing `## Links here` section is generated navigation and is never translated.
   - Calls `list_translations` on the page to find an existing target twin and reads it too, so it neither duplicates an existing translation nor silently overwrites one. Compare the two documents by their nodes only: each facet has its own inbound links, so a twin whose `## Links here` differs, or has none, is not a structural divergence and never a reason to write.
   - Translates only the **missing** nodes into the target language: neutral encyclopedic voice, links woven onto nouns, blockquotes preserved, cross-links (`page:N` / `block:N`) carried over verbatim. A translation mirrors the source node's title and body, it does not summarize or expand.
   - Punctuates by the target language's own conventions, never by the source's. Restraint with the em-dash is an English convention: where the target language uses the mark as ordinary punctuation, or requires it, it is written, and carrying the English rule across produces prose a native reader sees as wrong. German sets off an aside with one freely; Russian puts one between subject and predicate when the copula is absent, and a translation that drops it is ungrammatical. Those are examples, not the list. This skill writes, so a rule applied blindly here lands in the wiki rather than in a report someone can refuse.
   - Writes the target page and its blocks, not descendant pages assigned to other page jobs. If the target page is absent, choose its parent from `pages_tree`: in a flat wiki use the wiki root; in a hierarchical wiki use the target-language translation twin of the source page parent, or the wiki root when the source page itself is top-level. Create it with `kind=page` and `language=<target>`. Reproduce block nesting by parenting each translated block under the translated twin of its source block parent. Then `link_translation` each new target node to its source twin.
   - Returns a compact report: the source page URL, the nodes it created and linked, and anything it chose not to touch (see below), with one-line reasons.
5. The caller aggregates the per-page reports into one markdown report, grouped by the categories below. The caller does not translate; it only orchestrates and summarizes.

## What it fills vs flags

The skill fills only unambiguous gaps: a source node with no target twin. Three situations are reported for a human, never auto-resolved, because each can be deliberate:

1. **Structural divergence.** A linked group exists, but its authored structure differs across languages. Compare child blocks separately from child pages. When `pages_tree=true`, compare each source page's translated page parent and its child-page groups; when false, page-parent divergence is not a meaningful category because ordinary pages are deliberately flat. Report count differences, misplaced page twins and diverging titles. Do not add, move or delete existing nodes to force a match.
2. **Stale translation.** A target node's source twin has a later `updated_at`, so the source changed after it was translated. Report it as possibly out of date. Do not re-translate silently.
3. **Orphan single-language node.** A node with no group, in a language that is neither source nor target. Report it so the human can decide which translation group it belongs to.

## Severity

- **Filled**: gaps the skill translated and linked this run. Each carries the new node URLs.
- **Review**: structural divergence and stale translations. A human confirms whether the asymmetry is intended.
- **Decide**: orphan nodes with no group. A human decides which translation group they belong to.
