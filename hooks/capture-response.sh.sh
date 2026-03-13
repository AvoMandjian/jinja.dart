#!/bin/bash

# afterAgentResponse hook for Ralph Loop.
# Checks if the agent's response contains a matching completion promise.
# If found, writes a done flag so the stop hook knows to end the loop.
#
# Input:  { "text": "<assistant response text>" }
# Output: none (fire-and-forget)

set -euo pipefail

HOOK_INPUT=$(cat)

PROJECT_DIR="${CURSOR_PROJECT_DIR:-.}"
STATE_FILE="$PROJECT_DIR/.cursor/ralph/scratchpad.md"
DONE_FLAG="$PROJECT_DIR/.cursor/ralph/done"

# No active loop, nothing to do
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Extract completion promise from state file frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Extract response text from hook input
RESPONSE_TEXT=$(echo "$HOOK_INPUT" | jq -r '.text // empty')

if [[ -z "$RESPONSE_TEXT" ]]; then
  exit 0
fi

# Persist response text to .cursor/responses for later inspection
RESPONSES_DIR="$PROJECT_DIR/.cursor/responses"
mkdir -p "$RESPONSES_DIR"

CONVERSATION_ID=$(echo "$HOOK_INPUT" | jq -r '.conversation_id // empty')
GENERATION_ID=$(echo "$HOOK_INPUT" | jq -r '.generation_id // empty')

if [[ -n "$CONVERSATION_ID" ]] && [[ -n "$GENERATION_ID" ]]; then
  RESPONSE_FILE="$RESPONSES_DIR/${CONVERSATION_ID}_${GENERATION_ID}.md"
else
  RESPONSE_FILE="$RESPONSES_DIR/response_$(date +%s).md"
fi

TMP_RESPONSE_FILE="${RESPONSE_FILE}.tmp.$$"
printf '%s\n' "$RESPONSE_TEXT" > "$TMP_RESPONSE_FILE"
mv "$TMP_RESPONSE_FILE" "$RESPONSE_FILE"

# No promise configured, nothing further to check
if [[ "$COMPLETION_PROMISE" = "null" ]] || [[ -z "$COMPLETION_PROMISE" ]]; then
  exit 0
fi

# Only treat the loop as complete if the LAST non-empty line is exactly `<promise>COMPLETION_PROMISE</promise>`.
LAST_LINE=$(printf '%s\n' "$RESPONSE_TEXT" | sed '/^[[:space:]]*$/d' | tail -n 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
EXPECTED_LINE="<promise>$COMPLETION_PROMISE</promise>"

if [[ "$LAST_LINE" = "$EXPECTED_LINE" ]]; then
  touch "$DONE_FLAG"
fi

exit 0
