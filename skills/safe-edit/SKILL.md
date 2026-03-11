---
name: safe-edit
description: Prevent silent edit failures with automatic fallback
version: 1.0.0
author: Gumi (@gumi-ink)
license: MIT
---

# safe-edit

Prevent silent edit failures with literal string matching (NOT regex), automatic backup, and post-verification.

## Problem

OpenClaw's `edit` tool fails when:
- Target text doesn't match exactly
- Special regex characters cause wrong matches
- Multi-line text can't be matched
- File write fails without recovery

## Solution

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

---

*By Gumi (@gumi-ink) - Tools that don't fail silently*
