#!/bin/bash
# safe-edit: Prevent silent edit failures with automatic fallback
# Usage: safeedit --file <path> --old <text> --new <text>

set -e

# Parse arguments
FILE=""
OLD_TEXT=""
NEW_TEXT=""
VERBOSE=false

default_fallback="append"

while [[ $# -gt 0 ]]; do
  case $1 in
    --file)
      FILE="$2"
      shift 2
      ;;
    --old)
      OLD_TEXT="$2"
      shift 2
      ;;
    --new)
      NEW_TEXT="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ -z "$FILE" ] || [ -z "$OLD_TEXT" ] || [ -z "$NEW_TEXT" ]; then
  echo "Usage: safeedit --file <path> --old <text> --new <text>"
  exit 1
fi

log() {
  if [ "$VERBOSE" = true ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
  fi
}

# Step 1: Pre-validation - check if file exists
if [ ! -f "$FILE" ]; then
  echo "ERROR: File not found: $FILE"
  exit 1
fi

# Step 2: Pre-validation - check if old text exists
if ! grep -q "$OLD_TEXT" "$FILE"; then
  echo "ERROR: Old text not found in file: $OLD_TEXT"
  echo "Tip: Use --verbose to see file content"
  if [ "$VERBOSE" = true ]; then
    echo "--- File content ---"
    cat "$FILE"
    echo "--- End ---"
  fi
  exit 1
fi

log "Pre-validation passed: old text found"

# Step 3: Attempt exact edit
if sed -i "s|$OLD_TEXT|$NEW_TEXT|g" "$FILE" 2>/dev/null; then
  log "Edit successful"
  
  # Step 4: Post-verification
  if grep -q "$NEW_TEXT" "$FILE"; then
    log "Post-verification passed: new text confirmed"
    echo "SUCCESS: File edited successfully"
    exit 0
  else
    echo "ERROR: Edit appeared to succeed but new text not found"
    exit 1
  fi
else
  log "Edit failed, trying fallback..."
fi

# Step 5: Fallback to append
log "Fallback: appending to end of file"
echo "" >> "$FILE"
echo "<!-- safe-edit fallback append -->" >> "$FILE"
echo "$NEW_TEXT" >> "$FILE"

if grep -q "$NEW_TEXT" "$FILE"; then
  log "Fallback successful: content appended"
  echo "SUCCESS: Content appended (fallback mode)"
  exit 0
fi

# Step 6: Final fallback - write to backup file
BACKUP_FILE="${FILE}.safeedit.$(date +%Y%m%d_%H%M%S).bak"
log "Final fallback: writing to backup file: $BACKUP_FILE"
cp "$FILE" "$BACKUP_FILE"
echo "" >> "$BACKUP_FILE"
echo "<!-- safe-edit backup -->" >> "$BACKUP_FILE"
echo "$NEW_TEXT" >> "$BACKUP_FILE"

if grep -q "$NEW_TEXT" "$BACKUP_FILE"; then
  log "Backup write successful"
  echo "WARNING: Original file could not be edited"
  echo "SUCCESS: Content written to backup: $BACKUP_FILE"
  exit 0
fi

# Step 7: Total failure - alert user
echo "CRITICAL: All fallback strategies failed"
echo "File: $FILE"
echo "Target text: $OLD_TEXT"
echo "Backup attempted: $BACKUP_FILE"
exit 1
