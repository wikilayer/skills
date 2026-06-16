---
description: Reader-perspective review of a wikilayer wiki — hooks, internal consistency, contradictions across pages, dull walls, missed opportunities. Advisory only. Pair with /wikilayer:lint when mechanical style checks also matter; review is more expensive, run less often. Use when the user asks to review a wiki, audit as a reader, or check before a major release.
---

# wikilayer:review

Advisory reader-perspective audit. Read each page, judge it, emit recommendations. Do not apply fixes.

Under design — categories TBD with the author.

## Procedure

1. Resolve target wiki from `$ARGUMENTS`.
2. `get_outline(<wiki-id>, max_depth=10)` once.
3. Read each page as a reader would.
4. Emit a markdown report grouped by page.

## Severity

- **High** — factual contradictions, missing or broken hooks.
- **Medium** — missed cross-links, tone violations.
- **Low** — phrasing, optional improvements.
