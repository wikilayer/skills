---
name: get-started
description: First steps with Wikilayer. Explains what it does, or finds or creates a wiki, reads its rules, writes a first page and hands back its link. Use when the user is new to Wikilayer, asks what it can do, or asks to start a wiki.
---

# Get started with Wikilayer

Wikilayer is a wiki the user reads in the browser and you edit through its tools. A wiki holds pages; a page holds blocks, one per section.

If the user only asks what Wikilayer can do, answer that in words and stop: describe wikis, pages and sections, private and public wikis, and that you can create, read, search and reorganise them. Write nothing until the user asks you to start with something concrete.

When the user asks to start:

1. Call `list_wikis` to see the wikis this account can read and the role it holds in each.
2. If the user names a wiki, use it. If they have none or want a new one, call `create_wiki`. It is private unless the user asks for a public one. Say so before making a wiki public: everything written to it is then readable on the open web and indexed by search engines.
3. If a call is refused because the wiki has rules, read them with `get_page_markdown(wiki_id=…, special_role='rules')` and pass the value it returns in `rules_read_and_agreed` on later calls. Follow those rules while writing there.
4. Before writing into an existing wiki, read its whole structure with `get_outline(max_depth=-1)`, continuing with `offset` until `has_more` is false, so a new page does not repeat one that exists and lands where a reader would look for it.
5. Write what the user asked for with `create_nodes`: a page per subject, a block per section of a page. If they gave no subject, ask for one. Do not type `#` headings into a body; a section is its own block.
6. After every write, give the user the link to what changed: join the response's `base_url` and the node's `url_path`.

Deleting pages, changing a wiki's visibility and sharing a page by a public link change what other people can see. Ask before doing any of these unless the user has just asked for exactly that.
