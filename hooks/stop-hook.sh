#!/bin/bash

# Ralph Loop stop hook.
# When the agent finishes a turn, this hook decides whether to feed the
# same prompt back for another iteration or let the session end.
#
# Cursor stop hook API:
#   Input:  { "status": "completed"|"aborted"|"error", "loop_count": N, ...common }
#   Output: { "followup_message": "<text>" }  to continue, or exit 0 with no output to stop

set -euo pipefail

HOOK_INPUT=$(cat)

PROJECT_DIR="${CURSOR_PROJECT_DIR:-.}"
STATE_FILE="$PROJECT_DIR/.cursor/ralph/scratchpad.md"
DONE_FLAG="$PROJECT_DIR/.cursor/ralph/done"

# No active loop. Let the session end.
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse state file frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Validate iteration is numeric
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: state file corrupted (iteration: '$ITERATION'). Stopping." >&2
  rm -f "$STATE_FILE" "$DONE_FLAG"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: state file corrupted (max_iterations: '$MAX_ITERATIONS'). Stopping." >&2
  rm -f "$STATE_FILE" "$DONE_FLAG"
  exit 0
fi

# Capture the LLM's last output and keep a single tagged block at the end of the scratchpad.
CONVERSATION_ID=$(echo "$HOOK_INPUT" | jq -r '.conversation_id // empty')
GENERATION_ID=$(echo "$HOOK_INPUT" | jq -r '.generation_id // empty')
RESPONSES_DIR="$PROJECT_DIR/.cursor/responses"
LAST_OUTPUT=""

# Prefer response snapshot saved by capture-response hook, if present.
if [[ -n "$CONVERSATION_ID" ]] && [[ -n "$GENERATION_ID" ]]; then
  RESPONSE_FILE="$RESPONSES_DIR/${CONVERSATION_ID}_${GENERATION_ID}.md"
  if [[ -f "$RESPONSE_FILE" ]]; then
    LAST_OUTPUT=$(cat "$RESPONSE_FILE")
  fi
fi

# Fallback to reading from transcript if no response file found.
if [[ -z "$LAST_OUTPUT" ]]; then
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')
  if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    LAST_OUTPUT=$(tail -n 1 "$TRANSCRIPT_PATH" \
      | jq -r 'select(.role == "assistant") 
               | (.message.content[]? 
                  | select(.type == "text") 
                  | .text) // empty' 2>/dev/null \
      | tail -n 1)
  fi
fi

if [[ -n "$LAST_OUTPUT" ]]; then
  LOG_TEMP_FILE="${STATE_FILE}.log.$$"
  # Remove any existing <LAST_LLM_RESPONSE>...</LAST_LLM_RESPONSE> block
  if grep -q '^<LAST_LLM_RESPONSE>$' "$STATE_FILE"; then
    awk '
      BEGIN { in_block = 0 }
      /^<LAST_LLM_RESPONSE>$/ {
        if (in_block == 0) {
          in_block = 1
          next
        } else {
          in_block = 0
          next
        }
      }
      {
        if (in_block == 0) {
          print
        }
      }
    ' "$STATE_FILE" > "$LOG_TEMP_FILE"
  else
    cat "$STATE_FILE" > "$LOG_TEMP_FILE"
  fi

  {
    echo "<LAST_LLM_RESPONSE>"
    echo "$LAST_OUTPUT"
    echo "<LAST_LLM_RESPONSE>"
  } >> "$LOG_TEMP_FILE"

  mv "$LOG_TEMP_FILE" "$STATE_FILE"
fi

# Check if completion promise was detected by the afterAgentResponse hook
if [[ -f "$DONE_FLAG" ]]; then
  echo "Ralph loop: completion promise fulfilled at iteration $ITERATION." >&2
  rm -f "$STATE_FILE" "$DONE_FLAG"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Ralph loop: max iterations ($MAX_ITERATIONS) reached." >&2
  rm -f "$STATE_FILE" "$DONE_FLAG"
  exit 0
fi

# Extract prompt text (everything after the closing --- in frontmatter)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph loop: no prompt text found in state file. Stopping." >&2
  rm -f "$STATE_FILE" "$DONE_FLAG"
  exit 0
fi

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# Build the followup message: iteration context + original prompt
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  read -r -d '' HEADER <<EOF || true
Ralph loop iteration $NEXT_ITERATION. To complete this iteration, the model must strictly obey the following rules:
1. Completion promise emission
   - Output <promise>${COMPLETION_PROMISE}</promise> only when the completion promise has been fully, verifiably satisfied.
   - Never emit <promise>${COMPLETION_PROMISE}</promise>:
     - as part of brainstorming or planning,
     - as a placeholder,
     - or based on assumptions that have not been confirmed in the current loop state.
2. State-driven behavior
   - ALWAYS CHECK <LAST_LLM_RESPONSE> to determine the current loop state before deciding any next action.
   - Interpret <LAST_LLM_RESPONSE> as the single source of truth for:
     - what has already been attempted,
     - what is currently blocked or pending,
     - and what the next concrete action should be.
   - Base every action in this iteration on that interpreted state; do not ignore, overwrite, or contradict information contained in <LAST_LLM_RESPONSE>.
Based on the <LAST_LLM_RESPONSE> below come up with a plan and execute it step by step.
EOF
else
  read -r -d '' HEADER <<EOF || true
Ralph loop iteration $NEXT_ITERATION. To complete this iteration, the model must strictly obey the following rules:
1. Completion promise emission
   - Output <promise>${COMPLETION_PROMISE}</promise> only when the completion promise has been fully, verifiably satisfied.
   - Never emit <promise>${COMPLETION_PROMISE}</promise>:
     - as part of brainstorming or planning,
     - as a placeholder,
     - or based on assumptions that have not been confirmed in the current loop state.
2. State-driven behavior
   - ALWAYS CHECK <LAST_LLM_RESPONSE> to determine the current loop state before deciding any next action.
   - Interpret <LAST_LLM_RESPONSE> as the single source of truth for:
     - what has already been attempted,
     - what is currently blocked or pending,
     - and what the next concrete action should be.
   - Base every action in this iteration on that interpreted state; do not ignore, overwrite, or contradict information contained in <LAST_LLM_RESPONSE>.
Based on the <LAST_LLM_RESPONSE> below come up with a plan and execute it step by step.
EOF
fi

FOLLOWUP="$HEADER

$PROMPT_TEXT"

# Output followup_message to continue the loop
jq -n --arg msg "$FOLLOWUP" '{"followup_message": $msg}'

exit 0
