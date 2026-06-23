---
description: Bring a wikilayer wiki's translations into parity with a target language. Audits cross-language coverage (missing translations, structural divergence, stale or orphan nodes), then translates and links the genuine gaps, leaving anything tagged i18n-exempt alone. Unlike /wikilayer:lint and /wikilayer:review this skill writes to the wiki. Use when the user asks to translate a wiki, fill its missing translations, or check translation parity.
---

# wikilayer:translations

Parity pass across languages. lint and review only advise; this skill also writes: it creates and links the translations a wiki is missing in a target language. It audits first, fills the genuine gaps, leaves deliberate asymmetries alone, and reports the judgment calls (structural divergence, staleness) for a human rather than forcing them.

## Model

Translations live as parallel nodes in the same wiki, grouped by `link_translation`: a topic has one node per language, all in one group. A wiki's `primary_language` is the source; source nodes carry that language or an empty `language` field. A target-language node is a translation linked into the same group.

A source node is a **gap** when no node in its translation group carries the target language, and it is not exempt. Filling a gap means translating the source node, creating the target node with `language` set, and linking the two.

## Procedure

The caller never holds page bodies. Bodies live inside subagents; the caller sees compact reports.

1. Resolve the target wiki and target language from `$ARGUMENTS` (for example "wiki 1 to en", or a URL plus a BCP 47 code). The wiki's `primary_language` is the source. If either is unclear, ask.
2. Read the rules once, since the server gates writes: `search_nodes(wiki_id=<manual>, tag="before-write", include_body=true)` and `tag="before-read"`. The manual id is in the server instructions. Translations must follow the [writing style](https://wikilayer.org/smee-again/wikilayer-howto/2992-writing-style) and avoid the [anti-patterns](https://wikilayer.org/smee-again/wikilayer-howto/3038-anti-patterns), same as any other write.
3. `get_outline(<wiki-id>, max_depth=10)` once. Each row carries `language` (omitted when empty). This is the structural map: source-language pages, existing target-language pages, and their nesting.
4. Spawn one general-purpose subagent per source page (skip pages whose whole subtree is already linked, and pages tagged `i18n-exempt`). Each subagent:
   - Reads the source page's **exact** content with `get_outline(<page-id>, max_depth=10, include_markdown=true)`, sorted by `sort_key`. Read the verbatim source, never WebFetch the `.md`, which a model can reword.
   - Calls `list_translations` on the page to find an existing target twin and reads it too, so it neither duplicates an existing translation nor silently overwrites one.
   - Translates only the **missing** nodes into the target language: neutral encyclopedic voice, links woven onto nouns, blockquotes preserved, cross-links (`page:N` / `block:N`) carried over verbatim, no em-dash. A translation mirrors the source node's title and body, it does not summarize or expand.
   - Writes the target subtree: create the target page first if absent (`create_nodes`, `kind=page`, `language=<target>`), then its blocks in source order (children inherit the page language). Then `link_translation` each new target node to its source twin.
   - Returns a compact report: the source page URL, the nodes it created and linked, and anything it chose not to touch (see below), with one-line reasons.
5. The caller aggregates the per-page reports into one markdown report, grouped by the categories below. The caller does not translate; it only orchestrates and summarizes.

## Exemptions

A node tagged `i18n-exempt` is deliberately single-language. The skill never translates it, never flags it as a gap, and lists it under Exempt so the choice stays visible. Tag the page to exempt its whole subtree, or a block to exempt just that block. A wiki that wants some pages in one language only (a source-language-only appendix, a target-language-only note) marks them this way; everything untagged is assumed to want parity.

## What it fills vs flags

The skill fills only unambiguous gaps: a source node with no target twin and no exemption. Three situations are reported for a human, never auto-resolved, because each can be deliberate:

1. **Structural divergence.** A linked group exists, but the target subtree has more or fewer child nodes than the source (a target page deliberately richer or thinner than its source). Report the count difference and the diverging titles. Do not add or delete nodes to force a match.
2. **Stale translation.** A target node's source twin has a later `updated_at`, so the source changed after it was translated. Report it as possibly out of date. Do not re-translate silently.
3. **Orphan single-language node.** A node with no group and no `i18n-exempt` tag, in a language that is neither source nor target. Report it so the human either tags it exempt or links it.

## Severity

- **Filled**: gaps the skill translated and linked this run. Each carries the new node URLs.
- **Review**: structural divergence and stale translations. A human confirms whether the asymmetry is intended.
- **Decide**: orphan nodes with no group and no exemption. A human tags them exempt or links them.
- **Exempt**: nodes skipped by an `i18n-exempt` tag, listed so the deliberate gaps stay auditable.
