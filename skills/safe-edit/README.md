# safe-edit

Prevent silent edit failures with literal string matching (NOT regex), automatic backup, and post-verification.

## The Problem

OpenClaw's `edit` tool fails when:
- Target text doesn't match exactly
- Special regex characters cause wrong matches
- Multi-line text can't be matched
- File write fails without recovery

## The Solution

`safeedit.js` provides safe file editing with:

1. **Literal string matching** (NOT regex) - avoids injection attacks
2. **Pre-validation** - verifies target text exists before modifying
3. **Automatic backup** - creates timestamped backup before any changes
4. **Post-verification** - confirms changes were applied correctly
5. **Multi-line support** - handles complex code blocks

## Why Not Bash/sed

Traditional Bash/sed approaches have critical flaws:

| Approach | Problem | Example |
|----------|---------|---------|
| `sed s/old/new/g` | Treats input as regex | `a || b` becomes regex OR operator |
| `grep "text"` | Regex special chars fail | `const x = $y` `$` is regex anchor |
| Line-based tools | Can't match across lines | Multi-line functions fail |

**safe-edit** uses Node.js `content.split(old).join(new)` - pure literal matching.

## Installation

```bash
# Clone the skills repository
git clone https://github.com/gumi-ink/gumi-skills.git

# Copy skill to your OpenClaw workspace
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/
```

## Usage

### Basic
```bash
node ~/.openclaw/workspace/skills/safe-edit/safeedit.js \
  --file memory/2026-03-11.md \
  --old "## Todo" \
  --new "## Todo\n- [ ] New item"
```

### With verbose output
```bash
node ~/.openclaw/workspace/skills/safe-edit/safeedit.js \
  --file config.json \
  --old '"model": "old"' \
  --new '"model": "new"' \
  --verbose
```

### Multi-line replacement
```bash
node safeedit.js \
  --file app.js \
  --old 'function oldFunc() {
  return 1;
}' \
  --new 'function newFunc() {
  return 2;
}'
```

## How It Works

```
┌─────────────────────────────────────┐
│  1. Read file content               │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  2. Literal string search           │
│     (NOT regex)                     │
│     ├─ Found → Continue             │
│     └─ Not found → Error + exit     │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  3. Create timestamped backup       │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  4. Perform literal replacement     │
│     content.split(old).join(new)    │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  5. Verify replacement happened     │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  6. Write file                      │
│     ├─ Success → Done               │
│     └─ Fail → Restore from backup   │
└─────────────┬───────────────────────┘
              ▼
┌─────────────────────────────────────┐
│  7. Post-verification               │
│     Confirm new text in file        │
└─────────────────────────────────────┘
```

## Technical Details

### Literal vs Regex Matching

**❌ Traditional Bash/sed:**
```bash
# DANGEROUS: Treats $OLD as regex
sed -i "s|$OLD|$NEW|g" file
# Fails on: OLD='const x = a || b' (contains ||)
```

**✅ safe-edit (Node.js):**
```javascript
// SAFE: Literal string matching
content.split(oldText).join(newText)
// Works with: oldText='const x = a || b'
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (edit completed and verified) |
| 1 | Failure (pre-validation failed or verification failed) |

## Security Features

- **No regex injection**: Uses literal string matching
- **No shell injection**: Pure Node.js, no shell subprocesses
- **Automatic backup**: Always creates backup before modifying
- **Atomic operations**: Backup → Write → Verify sequence

## License

MIT - Use it, improve it, share it.

---

*Built by Gumi.*
