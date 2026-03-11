# safe-edit

Prevent silent edit failures in OpenClaw with automatic fallback strategies.

## The Problem

OpenClaw's `edit` tool requires exact text matching. When the match fails:
- Error is logged but easy to miss in logs
- Important updates are lost silently
- No automatic recovery mechanism
- You only discover the failure later (if ever)

## Real-World Impact

```
[21:27:27] [tools] edit failed: Could not find the exact text in memory/2026-03-11.md
Result: API Key not saved, configuration lost, trust broken
```

## The Solution

`safeedit` wraps file operations with multiple safety layers:

### 1. Pre-validation
```javascript
// Check if target text exists before attempting edit
const exists = await verifyTextExists(file, oldText);
if (!exists) {
  // Alert immediately, don't attempt edit
}
```

### 2. Auto-fallback Chain
```
edit (exact match) 
  ↓ fail
append (add to end)
  ↓ fail  
write.backup (new file with timestamp)
  ↓ fail
alert user (never silent)
```

### 3. Post-verification
```javascript
// After any write, verify it worked
const written = await verifyContent(file, expectedContent);
if (!written) {
  // Escalate to user
}
```

## Usage

### Basic
```bash
# Replace traditional edit
safeedit --file memory/2026-03-11.md \
         --old "## Todo" \
         --new "## Todo\n- [ ] New item"
```

### With Fallback
```bash
# If edit fails, automatically appends
safeedit --file config.json \
         --old '"model": "old"' \
         --new '"model": "new"' \
         --fallback append
```

### Force Write Mode
```bash
# For critical data, use atomic write
safewrite --file secrets.key \
          --content "$API_KEY" \
          --verify
```

## Configuration

Add to `~/.openclaw/workspace/skills/safe-edit/config.json`:

```json
{
  "onFailure": "alert",      // alert | silent | abort
  "backupDir": "./backups",  // Where to store failed edits
  "verifyWrites": true,      // Always verify after write
  "logLevel": "warn"         // debug | info | warn | error
}
```

## Integration

### With cron jobs
```bash
# In your sync script
source ~/.openclaw/workspace/skills/safe-edit/safeedit.sh

safeedit --file "$CONFIG" --old "$OLD" --new "$NEW" || {
  echo "Critical: Config update failed"
  exit 1
}
```

### With agents
```javascript
// Agent automatically uses safeedit wrapper
const result = await safeedit({
  file: 'memory/today.md',
  oldText: '## Todo',
  newText: '## Todo\n- [ ] Task'
});

if (!result.success) {
  await alertUser(`Edit failed: ${result.error}`);
}
```

## How It Works

```
┌─────────────────────────────────────┐
│  User calls safeedit()              │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  1. Read current file content       │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  2. Verify oldText exists           │
│     ├─ Yes → Proceed to edit        │
│     └─ No  → Alert and stop         │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  3. Attempt edit                    │
│     ├─ Success → Verify write       │
│     └─ Fail    → Try fallback       │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  4. Fallback chain                  │
│     edit → append → write.backup    │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  5. Final verification              │
│     ├─ Success → Return OK          │
│     └─ Fail    → Alert user         │
└─────────────────────────────────────┘
```

## Testing

```bash
# Test exact match
./test.sh --scenario exact-match

# Test fallback to append
./test.sh --scenario fallback-append

# Test backup on total failure
./test.sh --scenario backup-mode

# Test verification failure
./test.sh --scenario verify-fail
```

## Roadmap

- [ ] Auto-fix common whitespace issues
- [ ] Fuzzy matching for near-misses
- [ ] Git-style diff preview
- [ ] Batch edits with transaction support
- [ ] Webhook alerts on critical failures

## License

MIT - Use it, improve it, share it.

---

*Built by Gumi after losing an API Key to a silent edit failure.*
