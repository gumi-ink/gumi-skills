#!/usr/bin/env node
/**
 * safe-edit: Prevent silent edit failures with automatic fallback
 * Uses literal string replacement (NOT regex) to avoid injection issues
 */

const fs = require('fs');
const path = require('path');

function log(message) {
  const timestamp = new Date().toISOString().replace('T', ' ').slice(0, 19);
  console.log(`[${timestamp}] ${message}`);
}

function safeEdit(filePath, oldText, newText, options = {}) {
  const verbose = options.verbose || false;
  
  // Step 1: Pre-validation - check if file exists
  if (!fs.existsSync(filePath)) {
    console.error(`ERROR: File not found: ${filePath}`);
    return { success: false, error: 'File not found' };
  }
  
  // Step 2: Read file content
  let content;
  try {
    content = fs.readFileSync(filePath, 'utf-8');
  } catch (err) {
    console.error(`ERROR: Cannot read file: ${err.message}`);
    return { success: false, error: 'Read failed' };
  }
  
  // Step 3: Pre-validation - check if oldText exists (literal match, NOT regex)
  if (!content.includes(oldText)) {
    console.error(`ERROR: Old text not found in file`);
    if (verbose) {
      console.error('--- File content (first 500 chars) ---');
      console.error(content.slice(0, 500));
      console.error('--- End preview ---');
    }
    return { success: false, error: 'Old text not found' };
  }
  
  if (verbose) log('Pre-validation passed: old text found');
  
  // Step 4: Perform literal replacement (NOT regex)
  // Using split/join to avoid regex special character issues
  const newContent = content.split(oldText).join(newText);
  
  // Step 5: Verify replacement actually happened
  if (newContent === content) {
    console.error('ERROR: Replacement produced no changes');
    return { success: false, error: 'No changes made' };
  }
  
  // Step 6: Backup original file
  const backupPath = `${filePath}.safeedit.${Date.now()}.bak`;
  try {
    fs.copyFileSync(filePath, backupPath);
    if (verbose) log(`Backup created: ${backupPath}`);
  } catch (err) {
    console.error(`WARNING: Could not create backup: ${err.message}`);
    // Continue anyway, but warn
  }
  
  // Step 7: Write new content
  try {
    fs.writeFileSync(filePath, newContent, 'utf-8');
    if (verbose) log('File written successfully');
  } catch (err) {
    console.error(`ERROR: Write failed: ${err.message}`);
    // Attempt restore from backup
    try {
      fs.copyFileSync(backupPath, filePath);
      log('Restored from backup after write failure');
    } catch (restoreErr) {
      console.error(`CRITICAL: Restore failed: ${restoreErr.message}`);
    }
    return { success: false, error: 'Write failed' };
  }
  
  // Step 8: Post-verification
  let verifyContent;
  try {
    verifyContent = fs.readFileSync(filePath, 'utf-8');
  } catch (err) {
    console.error(`ERROR: Verification read failed: ${err.message}`);
    return { success: false, error: 'Verification failed' };
  }
  
  if (!verifyContent.includes(newText)) {
    console.error('ERROR: Post-verification failed: new text not found');
    return { success: false, error: 'Verification failed' };
  }
  
  if (verbose) log('Post-verification passed: new text confirmed');
  
  console.log('SUCCESS: File edited successfully');
  return { success: true, backupPath };
}

function showHelp() {
  console.log(`
Usage: node safeedit.js --file <path> --old <text> --new <text> [--verbose]

Options:
  --file <path>     Path to file to edit
  --old <text>      Text to find (literal match, NOT regex)
  --new <text>      Text to replace with
  --verbose         Enable verbose output
  --help            Show this help

Examples:
  node safeedit.js --file config.json --old '"version": "1.0"' --new '"version": "2.0"'
  node safeedit.js --file README.md --old '## Old Section' --new '## New Section' --verbose

Exit Codes:
  0 - Success
  1 - Failure (pre-validation failed or all fallbacks failed)
`);
}

function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--help') || args.length === 0) {
    showHelp();
    process.exit(0);
  }
  
  let filePath = null;
  let oldText = null;
  let newText = null;
  let verbose = false;
  
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--file':
        filePath = args[++i];
        break;
      case '--old':
        oldText = args[++i];
        break;
      case '--new':
        newText = args[++i];
        break;
      case '--verbose':
        verbose = true;
        break;
    }
  }
  
  if (!filePath || oldText === null || newText === null) {
    console.error('ERROR: Missing required arguments');
    console.error('Usage: node safeedit.js --file <path> --old <text> --new <text>');
    process.exit(1);
  }
  
  const result = safeEdit(filePath, oldText, newText, { verbose });
  process.exit(result.success ? 0 : 1);
}

main();
