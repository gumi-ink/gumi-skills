# safe-edit

> ⚠️ **CRITICAL UPDATE**: The original Bash implementation (`safeedit.sh`) has been **DEPRECATED** due to severe security and reliability issues identified in security audit.
> 
> **Use `safeedit.js` (Node.js) instead.**

## The Problem

OpenClaw's `edit` tool requires exact text matching. When the match fails:
- Error is logged but easy to miss in logs
- Important updates are lost silently
- No automatic recovery mechanism

## The Solution

`safeedit.js` provides safe file editing with:

1. **Literal string matching** (NOT regex) - avoids injection attacks
2. **Pre-validation** - verifies target text exists before modifying
3. **Automatic backup** - creates timestamped backup before any changes
4. **Post-verification** - confirms changes were applied correctly
5. **Safe fallback** - restores from backup on write failure

## Why Bash Version Failed (Security Audit Findings)

The original `safeedit.sh` was deprecated due to:

| Issue | Impact |
|-------|--------|
| **Regex injection** | `sed` treats input as regex, special chars (`*`, `.`, `$`) cause wrong matches |
| **Separator collision** | `sed` using `\|` fails when text contains `\|\|` |
| **Multi-line failure** | `sed` can't match across lines, complex code blocks always fail |
| **Destructive append** | Fallback appends to EOF, corrupts JSON/JS/Python syntax |

## Installation

```bash
# Clone the skills repository
git clone https://github.com/gumi-ink/gumi-skills.git

# Copy skill to your OpenClaw workspace
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/

# Make executable (optional, for direct usage)
chmod +x ~/.openclaw/workspace/skills/safe-edit/safeedit.js
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

### Multi-line replacement (works correctly)
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
│     (NOT regex - safe from injection)│
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

**❌ Bash/sed (DEPRECATED):**
```bash
# DANGEROUS: Treats $OLD as regex
sed -i "s|$OLD|$NEW|g" file
# Fails on: OLD='const x = a || b' (contains ||)
```

**✅ Node.js (CURRENT):**
```javascript
// SAFE: Literal string matching
content.split(oldText).join(newText)
// Works with: oldText='const x = a || b'
```

### Multi-line Support

**❌ Bash/sed:** Cannot match across newlines by default

**✅ Node.js:** Full multi-line support via string operations

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (edit completed and verified) |
| 1 | Failure (pre-validation failed, write failed, or verification failed) |

## Security Considerations

- **No regex injection**: Uses literal string matching
- **No shell injection**: Pure Node.js, no shell subprocesses
- **Automatic backup**: Always creates backup before modifying
- **Atomic operations**: Backup → Write → Verify sequence

## Deprecated Files

- `safeedit.sh` - **DEPRECATED**: Do not use. Contains regex injection and multi-line bugs.

## License

MIT - Use it, improve it, share it.

---

*Built by Gumi. Security audit and Node.js rewrite prompted by community feedback.*
