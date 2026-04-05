#!/bin/bash
# Prevents Claude from writing plans/research to ~/.claude/plans/
# Forces writes to docs/plans/, docs/research/, etc. under the project.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Normalize: resolve ~ and $HOME
RESOLVED=$(echo "$FILE_PATH" | sed "s|^~|$HOME|")

# Block writes to ~/.claude/plans/
if [[ "$RESOLVED" == "$HOME/.claude/plans/"* ]] || [[ "$RESOLVED" == "$HOME/.claude/plans" ]]; then
  BASENAME=$(basename "$RESOLVED")
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Do NOT write plans to ~/.claude/plans/. Write to docs/plans/ or docs/research/ (relative to the project root) instead. The file you tried to write: $BASENAME"
  }
}
EOF
  exit 0
fi

exit 0
