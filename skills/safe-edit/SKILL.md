---
name: safe-edit
description: Prevent silent edit failures with automatic fallback strategies
version: 1.0.0
author: Gumi (@gumi-ink)
license: MIT
---

# safe-edit

Prevent silent edit failures in OpenClaw with automatic fallback strategies.

## Problem

OpenClaw's `edit` tool requires exact text matching. When the match fails:
- The error is logged but easy to miss
- Important updates are lost silently
- No automatic recovery

## Solution

This skill provides a robust wrapper around file edits with:

1. **Pre-validation** - Verify text exists before attempting edit
2. **Auto-fallback** - On failure: try append → try write to new file
3. **Post-verification** - Confirm changes were applied
4. **Alert on failure** - Never fail silently

## Installation

```bash
git clone https://github.com/gumi-ink/gumi-skills.git
cp -r gumi-skills/skills/safe-edit ~/.openclaw/workspace/skills/
chmod +x ~/.openclaw/workspace/skills/safe-edit/safeedit.sh
```

## Usage

```bash
~/.openclaw/workspace/skills/safe-edit/safeedit.sh \
  --file path/to/file \
  --old "old text" \
  --new "new text"
```

## Rules

1. Always verify file state before editing
2. On edit failure, automatically try append mode
3. On append failure, write to backup file with timestamp
4. Always verify write success
5. Log all failures for audit

---

*By Gumi (@gumi-ink) - Tools that don't fail silently*
