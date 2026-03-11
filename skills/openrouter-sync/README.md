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
# Clone and install
git clone https://github.com/gumi-ink/gumi-skills.git
cd gumi-skills/skills/openrouter-sync

# Set up API key
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

## Configuration

Edit `~/.openclaw/workspace/skills/openrouter-sync/config.json`:

```json
{
  "apiKeyFile": "~/.openclaw/openrouter.key",
  "logFile": "~/.openclaw/logs/openrouter-sync.log",
  "backupConfigs": true,
  "alertOnChange": true,
  "alertChannel": "feishu",
  "preferredModels": [
    "google/gemma-3-27b-it:free",
    "meta-llama/llama-3.3-70b-instruct:free"
  ]
}
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

### Force update
```bash
~/.openclaw/workspace/skills/openrouter-sync/sync.sh --force
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

## Alert Triggers

Get notified when:
- New free model added (opportunity)
- Free model removed (need to migrate)
- API key invalid (action needed)
- Sync fails 3 times in a row (system issue)

## Model Selection Strategy

The sync maintains a priority list:

```
Tier 1 (High Priority):
- google/gemma-3-27b-it:free
- meta-llama/llama-3.3-70b-instruct:free
- nousresearch/hermes-3-llama-3.1-405b:free

Tier 2 (Medium Priority):
- mistralai/mistral-small-3.1-24b-instruct:free
- google/gemma-3-12b-it:free

Tier 3 (Backup):
- qwen/qwen3-4b:free
- google/gemma-3-4b-it:free
```

## Integration with safe-edit

Uses safe-edit internally to prevent config corruption:
```bash
# If config update fails, safe-edit will:
# 1. Try exact match edit
# 2. Fall back to append
# 3. Create backup file
# 4. Alert user
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

# Check job logs
openclaw cron logs openrouter-sync
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
│  Compare with current config            │
│  ├─ No change → Log and exit            │
│  └─ Changes   → Proceed                 │
└─────────────┬───────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  Backup current config                  │
│  Update with safe-edit                  │
│  Verify models accessible               │
└─────────────┬───────────────────────────┘
              ▼
┌─────────────────────────────────────────┐
│  Log results                            │
│  Alert if significant changes           │
└─────────────────────────────────────────┘
```

## Cost Analysis

- **API calls**: 1/day × 30 days = 30 calls/month
- **Cost**: $0 (OpenRouter API is free for model listing)
- **Value**: Never miss a free model, avoid using deprecated ones

## Related

- [OpenRouter Pricing](https://openrouter.ai/docs#pricing)
- [OpenRouter Models API](https://openrouter.ai/docs#models)
- [safe-edit](../safe-edit/) - Used for config updates

## License

MIT

---

*Never pay for a model that's available for free.*
