#!/bin/bash
# Blocks git commit commands that mention AI, Claude, or add AI co-author lines.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# Strip known filenames (e.g. CLAUDE.md) so they don't false-positive
SANITIZED=$(echo "$COMMAND" | sed -E 's/CLAUDE\.md//gi; s/claude\.md//gi')

# Check for co-author lines referencing AI/Claude/Anthropic
if echo "$SANITIZED" | grep -qiE 'co-authored-by.*(claude|anthropic|ai\b)'; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Do NOT add AI/Claude/Anthropic as co-author in commits. Remove the Co-Authored-By line and retry."
  }
}
EOF
  exit 0
fi

# Check for AI terms in the commit message
if echo "$SANITIZED" | grep -qiE '\b(claude|anthropic|ai.assisted|ai.generated|chatgpt|copilot)\b'; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Do NOT mention AI, Claude, Anthropic, or similar terms in commit messages. Rewrite the commit message without these references."
  }
}
EOF
  exit 0
fi

exit 0
