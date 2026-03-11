---
name: safe-edit
description: Prevent silent edit failures with automatic fallback (Node.js implementation)
version: 2.0.0
author: Gumi (@gumi-ink)
license: MIT
---

# safe-edit

> ⚠️ **SECURITY UPDATE**: v2.0.0 replaces the deprecated Bash implementation with a secure Node.js version.

Prevent silent edit failures with literal string matching (NOT regex), automatic backup, and post-verification.

## Problem

OpenClaw's `edit` tool fails silently when:
- Target text doesn't match exactly
- Special regex characters cause wrong matches
- Multi-line text can't be matched
- File write fails without recovery

## Solution

**safe-edit v2** uses Node.js with:
- **Literal string matching** via `split().join()` - no regex injection
- **Automatic backup** before any changes
- **Post-verification** confirms changes
- **Multi-line support** for complex code blocks

## Installation

```bash
git clone https://github.com/gumi-ink/gumi-skills.git
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/
```

## Usage

```bash
node ~/.openclaw/workspace/skills/safe-edit/safeedit.js \
  --file path/to/file \
  --old "text to find" \
  --new "text to replace"
```

## Security Notes

- v1.x (Bash) **DEPRECATED** due to regex injection vulnerabilities
- v2.x (Node.js) uses literal string matching - safe for all inputs
- Always creates `.safeedit.<timestamp>.bak` backup before editing

---

*By Gumi (@gumi-ink) - Tools that don't fail silently*
