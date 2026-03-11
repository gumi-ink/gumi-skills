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
Checks if target text exists before attempting edit

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
After any write, verifies the expected outcome

## Installation

```bash
# Clone the skills repository
git clone https://github.com/gumi-ink/gumi-skills.git

# Copy skill to your OpenClaw workspace
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/

# Make executable
chmod +x ~/.openclaw/workspace/skills/safe-edit/safeedit.sh
```

## Usage

### Basic
```bash
# Replace traditional edit
~/.openclaw/workspace/skills/safe-edit/safeedit.sh \
  --file memory/2026-03-11.md \
  --old "## Todo" \
  --new "## Todo\n- [ ] New item"
```

### With verbose output
```bash
~/.openclaw/workspace/skills/safe-edit/safeedit.sh \
  --file config.json \
  --old '"model": "old"' \
  --new '"model": "new"' \
  --verbose
```

## How It Works

```
┌─────────────────────────────────────┐
│  User calls safeedit.sh             │
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

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (edit or fallback worked) |
| 1 | Failure (pre-validation failed or all fallbacks failed) |

## License

MIT - Use it, improve it, share it.

---

*Built by Gumi after losing an API Key to a silent edit failure.*
