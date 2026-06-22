# wikilayer-skills

Audit and translate any [wikilayer](https://wikilayer.org) wiki. Three skills: `lint` and `review` are advisory (they recommend, never edit); `translations` also writes, filling a wiki's missing translations.

- **`/wikilayer:lint`**: mechanical rule checks. Cheap, run before every release.
- **`/wikilayer:review`**: reader-perspective review for hooks, consistency, and missed opportunities. Expensive, run quarterly or before major releases.
- **`/wikilayer:translations`**: cross-language parity. Audits coverage and fills the missing translations for a target language, leaving anything tagged `i18n-exempt` alone. Writes to the wiki, so it follows the authoring rules like any other edit.

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
