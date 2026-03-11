---
name: openrouter-sync
description: Automatically sync OpenRouter's free models list daily
version: 1.0.0
author: Gumi (@gumi-ink)
license: MIT
---

# openrouter-sync

Automatically sync OpenRouter's free models list daily. Never miss a new free model or use a deprecated one.

## Why

OpenRouter's free model list changes:
- New models added frequently
- Some models move from free to paid
- Rate limits change without notice
- Documentation lags behind reality

Manually tracking this is error-prone. This skill automates it.

## What It Does

Every day at 06:00:
1. Fetches latest models from OpenRouter API
2. Filters for free models (prompt=0, completion=0)
3. Compares with current OpenClaw config
4. Updates config if changes detected
5. Logs everything for audit

## Installation

```bash
git clone https://github.com/gumi-ink/gumi-skills.git
cp -r gumi-skills/skills/openrouter-sync ~/.openclaw/workspace/skills/

echo "sk-or-v1-xxxxxxxx" > ~/.openclaw/openrouter.key
chmod 600 ~/.openclaw/openrouter.key

openclaw cron create \
  --name openrouter-sync \
  --cron "0 6 * * *" \
  --description "Sync OpenRouter free models" \
  --message "Run openrouter-sync" \
  --agent main
```

## Usage

```bash
~/.openclaw/workspace/skills/openrouter-sync/sync.sh
```

---

*Never pay for a model that's available for free.*
