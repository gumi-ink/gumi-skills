#!/bin/bash
# OpenRouter Free Models Auto-Updater
# Fetches latest free models and updates OpenClaw config

set -e

CONFIG_FILE="${HOME}/.openclaw/openclaw.json"
LOG_FILE="${HOME}/.openclaw/logs/openrouter-sync.log"
API_KEY_FILE="${HOME}/.openclaw/openrouter.key"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Get API key
if [ -f "$API_KEY_FILE" ]; then
  API_KEY=$(cat "$API_KEY_FILE" | tr -d '\n')
else
  log "ERROR: API key not found at $API_KEY_FILE"
  exit 1
fi

if [ -z "$API_KEY" ]; then
  log "ERROR: API key is empty"
  exit 1
fi

log "Fetching OpenRouter free models..."

# Fetch models from OpenRouter
RESPONSE=$(curl -s -w "\n%{http_code}" https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" 2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "200" ]; then
  log "ERROR: API request failed with code $HTTP_CODE"
  log "Response: $BODY"
  exit 1
fi

# Extract free models (pricing.prompt = 0 and pricing.completion = 0)
# Using tonumber to handle both string "0" and number 0, as well as "0.0"
FREE_MODELS=$(echo "$BODY" | jq -r '.data[] | select((.pricing.prompt | tonumber) == 0 and (.pricing.completion | tonumber) == 0) | .id' 2>/dev/null)

if [ -z "$FREE_MODELS" ]; then
  log "WARNING: No free models found"
  exit 0
fi

MODEL_COUNT=$(echo "$FREE_MODELS" | grep -c '^' || echo "0")
log "Found $MODEL_COUNT free models"

# Build models array for config
MODELS_ARRAY=""
while IFS= read -r model; do
  if [ -n "$model" ]; then
    name=$(echo "$model" | sed 's/.*\///' | sed 's/:free//')
    if [ -n "$MODELS_ARRAY" ]; then
      MODELS_ARRAY="${MODELS_ARRAY},"
    fi
    MODELS_ARRAY="${MODELS_ARRAY}{\"id\": \"$model\", \"name\": \"$name (Free)\"}"
  fi
done <<< "$FREE_MODELS"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  log "ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Backup current config
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
log "Config backed up to: $BACKUP_FILE"

# Update config using openclaw CLI
if openclaw config set 'models.providers.openrouter.models' "[$MODELS_ARRAY]" --strict-json 2>/dev/null; then
  log "Config updated successfully"
else
  log "ERROR: Failed to update config"
  # Restore backup
  cp "$BACKUP_FILE" "$CONFIG_FILE"
  log "Config restored from backup"
  exit 1
fi

# Verify models are accessible
NEW_MODELS=$(openclaw models list --all 2>/dev/null | grep -c "openrouter/" || echo "0")
log "Verified $NEW_MODELS openrouter models in list"

# Check for changes
CURRENT_MODELS=$(echo "$FREE_MODELS" | sort)
log "Sync completed successfully"
log "Models: $MODEL_COUNT free models configured"
