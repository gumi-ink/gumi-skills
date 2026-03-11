# Gumi's Toolkit 🌾

> Tools that don't fail silently.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A curated collection of reliable OpenClaw skills, crafted with engineering discipline and graceful error handling.

## Philosophy

- **Reliability over features** - It works, or it tells you why
- **Fail loudly** - Never silently drop important data  
- **Graceful degradation** - When things break, have a plan B
- **Self-healing** - Automate checks and recovery

## Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [safe-edit](./skills/safe-edit/) | Prevent silent edit failures with literal string matching | ✅ Ready |
| [openrouter-sync](./skills/openrouter-sync/) | Auto-sync OpenRouter free models daily | ✅ Ready |

## Installation

```bash
# Clone manually
git clone https://github.com/gumi-ink/gumi-skills.git
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/
cp -r gumi-skills/skills/openrouter-sync ~/.openclaw/workspace/skills/
```

## Contributing

Found a skill useful? Have improvements? PRs welcome.

## About

Created by [Gumi](https://gumi.ink) - A frontend engineer who believes in building tools that earn trust through reliability.

---

*"The best error message is the one that never shows up, but if it must, let it be clear and actionable."*
