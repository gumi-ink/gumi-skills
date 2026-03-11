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
6. Alerts on significant changes

## Installation

```bash
# Clone the skills repository
git clone https://github.com/gumi-ink/gumi-skills.git

# Copy skill to your OpenClaw workspace
cp -r gumi-skills/skills/openrouter-sync ~/.openclaw/workspace/skills/

# Set up your OpenRouter API key
echo "sk-or-v1-xxxxxxxx" > ~/.openclaw/openrouter.key
chmod 600 ~/.openclaw/openrouter.key

# Install cron job
openclaw cron create \
  --name openrouter-sync \
  --cron "0 6 * * *" \
  --description "Sync OpenRouter free models" \
  --message "Run openrouter-sync" \
  --agent main
```

## Usage

### Manual sync
```bash
~/.openclaw/workspace/skills/openrouter-sync/sync.sh
```

### Check last sync
```bash
tail ~/.openclaw/logs/openrouter-sync.log
```

## Log Format

```
[2026-03-11 06:00:01] Fetching OpenRouter free models...
[2026-03-11 06:00:02] Found 47 free models
[2026-03-11 06:00:02] Changes detected:
  + google/gemma-3-27b-it:free (NEW)
  - meta-llama/llama-3.1-8b:free (REMOVED)
[2026-03-11 06:00:03] Config updated successfully
[2026-03-11 06:00:03] Verified 47 openrouter models in list
[2026-03-11 06:00:03] Sync completed
```

## Troubleshooting

### API returns empty list
```bash
# Check API key
curl -H "Authorization: Bearer $(cat ~/.openclaw/openrouter.key)" \
  https://openrouter.ai/api/v1/auth/key
```

### Config not updating
```bash
# Check permissions
ls -la ~/.openclaw/openclaw.json

# Verify openclaw CLI works
openclaw config get models.providers.openrouter
```

### Cron job not running
```bash
# List all cron jobs
openclaw cron list
```

## Architecture

```
┌─────────────────────────────────────────┐
│  Cron Trigger (06:00 daily)             │
└─────────────┬───────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  Fetch /api/v1/models                   │
│  Filter: pricing.prompt == 0            │
│           pricing.completion == 0       │
└─────────────┬───────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  Backup current config                  │
│  Update with openclaw CLI               │
│  Verify models accessible               │
└─────────────┬───────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  Log results                            │
└─────────────────────────────────────────┘
```

## Cost Analysis

- **API calls**: 1/day × 30 days = 30 calls/month
- **Cost**: $0 (OpenRouter API is free for model listing)
- **Value**: Never miss a free model, avoid using deprecated ones

## Related

- [OpenRouter Pricing](https://openrouter.ai/docs#pricing)
- [OpenRouter Models API](https://openrouter.ai/docs#models)

## License

MIT

---

*Never pay for a model that's available for free.*
