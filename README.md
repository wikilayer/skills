# wikilayer-skills

Audit any [wikilayer](https://wikilayer.org) wiki. Two skills, both advisory — they recommend, they do not edit.

- **`/wikilayer:lint`** — mechanical rule checks. Cheap, run before every release.
- **`/wikilayer:review`** — reader-perspective review for hooks, consistency, and missed opportunities. Expensive, run quarterly or before major releases.

## Install

```bash
git clone git@github.com:wikilayer/skills.git wikilayer-skills
claude --plugin-dir ./wikilayer-skills
```

## Update

```bash
cd wikilayer-skills && git pull
```

Then in Claude Code:

```
/reload-plugins
```
