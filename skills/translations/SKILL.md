---
name: translations
description: Bring a wikilayer wiki, or one page in it, into translation parity with a target language. Audits cross-language coverage (missing translations, structural divergence, stale translations, possible unlinked twins, links that send a reader into another language), then translates and links the missing pages. A page target fills only that page's subtree, for a page just added or reworked. Unlike the wikilayer lint and review skills this skill writes to the wiki. Use when the user asks to translate a wiki or a single page, fill its missing translations, or check translation parity.
---

# wikilayer:translations

Parity pass across languages. lint and review only advise; this skill also writes: it creates and links the translations a wiki is missing in a target language. It audits first, fills the gaps, and reports the judgment calls for a human rather than forcing them.

## Model

Translations live as parallel nodes in the same wiki, grouped by `link_translation`: a topic has one node per language, all in one group. A wiki's `primary_language` is the source; source nodes carry that language or an empty `language` field. A target-language node is a translation linked into the same group.

Each language has its own front page, in the `home` role for that language; front pages pair by role rather than by a link, and their blocks are linked like any other. The rules page exists only in the primary language and is never translated.

A language is a facet with a life of its own, not a mirror. A target page may hold a block or a link the source does not, and may leave out one the source has. So the skill fills what is missing only where nothing has been written yet, and a link in a target body names a target-language node.

A source node is a **gap** when no node in its group carries the target language. A gap is **filled** when it is a page with no target twin, a block of a page whose target twin this run created, or a block of a page the user named as the target of a page-scoped run. On a whole-wiki run, a missing block on a target page that already existed is reported, not filled: its author may have left it out. Naming the page is the human's decision to fill it.

## Procedure

Hold no page body in the caller: keep only ids, titles, outline rows and subagent reports, and leave reading and translating bodies to subagents.

1. Resolve the target and target language from the user's request (for example "wiki 1 to en", or a URL plus a BCP 47 code). Resolve the wiki with `list_wikis` and take its `primary_language` as the source; never infer it from the outline. If the target or target language is unclear, ask.

   **Scope.** A `wiki` target brings the whole wiki to parity; a `page` target fills only that page's subtree, for example a page just added or reworked. The map comes from the whole wiki; everything else, gaps and reports included, stays inside the scope.
2. Read and accept every rules page the server asks for, and carry the returned signatures on every call they bind. Read them again when a call is refused for them. A translation is a write like any other, so it answers to [what a node holds](https://wikilayer.org/smee-again/wikilayer-howto/54721-pages-and-nodes) and to [wording and marks](https://wikilayer.org/smee-again/wikilayer-howto/54729-wording).
3. Call `get_outline(<wiki-id>, max_depth=0, language=<primary>)`. If its `languages` do not include the target, or it names none, call `add_language` for the target. Without the right to, stop and say so.
4. Read the structural map: `get_outline` at `max_depth=-1` once with `language=<primary>` and once with `language=<target>`, each through every page of results, with `fields=["id","kind","title","special_role","parent_id","depth","sort_key","updated_at"]`.
5. Call `list_translations(wiki_id, node_ids)` over every page and block of both outlines, leaving out the wiki row and the rules page with its subtree. From the answer take:
   - the **map** from each source node to its target twin, the front pages included through `paired_by_role`;
   - the **gaps**: source nodes with no target twin;
   - the **unlinked target pages**: target-language pages in no group. Most are the facet's own; they matter only as possible twins of a gap page under the same parent's twin.
   - **stale pairs**: a target twin whose source has a later `updated_at`.
6. **Pages first, titles only.** Create every missing target page in scope before any body, so that every body can link a target page that exists. Go by depth; no page is created before its parent's twin. Hand each depth to one subagent with the source pages' ids, titles and `sort_key`s, their parents' target twins, the unlinked target pages under those twins, the target language, the wiki id and the signatures. Where an unlinked target page is plainly the same subject as a source page, the subagent creates nothing for it and reports the pair. Otherwise it creates each page with `kind=page`, `language=<target>`, the translated title and the source page's `sort_key`, under the target twin of the source page's parent, or under the wiki root for a top-level source page, then links them to their source pages with `link_translation(wiki_id, nodes=[{node_id, other_node_id}, …])`, up to 100 pairs a call, and returns the id pairs and URLs, which go into the map. On a page-scoped run, a source page whose parent twin is missing and outside the scope is reported as a prerequisite and not created; never fall back to the root or another convenient parent.
7. **Then bodies.** Hand each target page in scope to one subagent, the front page included when it is in scope; a front page counts as created this run when step 3 added the language. Run them in parallel. Launch each subagent with an explicitly chosen model, and effort where the client takes one, rather than the session's: translation is judgment, so choose a strong one. Brief each with the source page id, its target twin, whether it may fill that twin (created this run, or the named page of a page-scoped run), the outline rows of the source page's blocks (id, parent, `sort_key`), the map's page pairs and the pairs of this page's blocks, the target language, the wiki id and the signatures.

   Each subagent:
   - Reads the source page and the target twin with `get_page_markdown`, never by WebFetch of the `.md` URL, which a model can reword. The `<!-- block:N -->` comment above each node is its id; the closing `## Links here` is generated navigation: never translate it, never compare it.
   - On a twin it may fill: writes the translated page lead where the twin has none, and on a front page created this run the translated title and lead, with `update_node`; then creates every missing block with `create_nodes`, a parent before its children, each under the target twin of its source parent and with its source `sort_key`; then links them to their source twins with `link_translation(wiki_id, nodes=…)`. On any other twin: writes nothing and lists the source blocks it has no twin of.
   - Translates in a neutral encyclopedic voice, weaving links onto nouns and keeping blockquotes, mirroring the source node's title and body without summarizing or expanding.
   - Points every `page:N` and `block:N` it writes at the target twin: from the map, else from `list_translations` on that node. `page:home` and `page:rules` stay as written. A link whose node has no twin yet, a block it is creating in the same call included, keeps the source id; step 8 repoints it.
   - Punctuates by the target language's own conventions, never by the source's. Restraint with the em-dash is an English convention: German sets off an aside with one freely, and Russian requires one between subject and predicate when the copula is absent. Those are examples, not the list.
   - Compares the twin's blocks with the source's and lists diverging titles and blocks out of source order. It does not list target-only blocks.
   - Returns: the page URL; created nodes as source-to-target id pairs with URLs; the twin's id if it wrote that twin's lead or title; blocks it found missing or diverging; anything it did not touch, with one-line reasons.
8. **Then the links left behind.** Call `search_nodes(wiki_id, language=<target>, links_across_languages=true, include_ancestors=false)`, with `subtree_id` set to the scope's target twin on a page-scoped run, through every page of results. Each hit's `cross_links` names every other-language target it links and that target's target-language `twin`, if any. In the nodes this run wrote (created in steps 6–7, plus each twin whose lead or title step 7 wrote), repoint every link that has a twin with `patch_node(wiki_id, nodes=[{node_id, replacements: [{old_target, new_target}, …]}, …])`, up to 100 nodes a call; a node the server refuses to retarget leaves the batch and goes into the report. A link without a twin stays and goes into the report. A crossing link in a node this run did not write is not rewritten, because a facet may link where it likes: it goes into the report, saying whether a twin exists.
9. Compare child pages yourself from the two outlines: a target page under a parent other than its source page's parent's twin is a misplaced twin. A top-level source page's twin belongs under the wiki root, not under the target front page. Then aggregate everything into one markdown report, grouped by the categories below, naming every node as a link. Leave all translating to the subagents.

## What it fills vs flags

It fills only gaps as defined above. Five situations go to a human, never resolved automatically, because each can be deliberate:

1. **Structural divergence.** A source block missing from a target page it may not fill, a diverging title, a block out of source order, a misplaced page twin. Target-only nodes are a facet's own and are not reported.
2. **Stale translation.** The source changed after its twin was written. Do not re-translate silently.
3. **Possible unlinked twin.** An unlinked target page that is plainly the same subject as a gap page under the same parent's twin; the gap was left unfilled.
4. **Link crossing languages.** A target body links a source-language node: either the target language has no twin of it, or an earlier translation carried the source id across although a twin exists. That facet's reader lands in another language.
5. **Prerequisite.** A page-scoped run could not create a page because its parent's twin is missing outside the scope.

## Severity

- **Filled**: gaps translated and linked this run, each as a link to the new node.
- **Review**: structural divergence, stale translations, links crossing languages and prerequisites. A human confirms whether the asymmetry is intended.
- **Decide**: possible unlinked twins. A human decides whether to link the pair or translate the gap anyway.
