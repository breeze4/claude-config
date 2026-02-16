#!/usr/bin/env bash
set -euo pipefail

# Gemini image generation script
# Usage: generate-image.sh "prompt text" [output_path]

PROMPT="${1:?Usage: generate-image.sh \"prompt\" [output_path]}"
OUTPUT_DIR="${2:-docs/images}"
FILENAME="${3:-$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | head -c 60 | sed 's/-$//')}.png"

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "Error: GEMINI_API_KEY environment variable is not set." >&2
  echo "Set it with: export GEMINI_API_KEY='your-key-here'" >&2
  exit 1
fi

# Check dependencies
for cmd in curl jq base64; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

mkdir -p "$OUTPUT_DIR"

OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"

echo "Generating image..."
echo "  Prompt: $PROMPT"
echo "  Output: $OUTPUT_PATH"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL:-gemini-3-pro-image-preview}:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg prompt "$PROMPT" \
    '{
      contents: [{
        parts: [{ text: $prompt }]
      }],
      generationConfig: {
        responseModalities: ["IMAGE"],
        imageConfig: {
          aspectRatio: "16:9"
        }
      }
    }'
  )")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Error: API returned HTTP $HTTP_CODE" >&2
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY" >&2
  exit 1
fi

# Extract base64 image data
IMAGE_DATA=$(echo "$BODY" | jq -r '.candidates[0].content.parts[] | select(.inlineData) | .inlineData.data' 2>/dev/null)

if [ -z "$IMAGE_DATA" ] || [ "$IMAGE_DATA" = "null" ]; then
  echo "Error: No image data in response." >&2
  echo "Response:" >&2
  echo "$BODY" | jq '.candidates[0].content.parts[] | select(.text) | .text' 2>/dev/null || echo "$BODY" >&2
  exit 1
fi

echo "$IMAGE_DATA" | base64 --decode > "$OUTPUT_PATH"

echo "Done: $OUTPUT_PATH ($(du -h "$OUTPUT_PATH" | cut -f1))"
