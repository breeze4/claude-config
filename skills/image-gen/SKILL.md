---
name: image-gen
description: Generate images using Google Gemini API and save to docs/images/. Use when asked to generate an image, create a diagram, or make a picture.
user_invocable: true
---

# Image Generator (Gemini)

Generate images via Google Gemini's native image generation (Nano Banana) and save them to the project's `docs/images/` directory.

## Usage

The user invokes this with a prompt describing what to generate:

```
/image-gen a system architecture diagram showing microservices
```

## Workflow

### 1. Check for API key

The `GEMINI_API_KEY` environment variable must be set. If not, tell the user:

```
export GEMINI_API_KEY='your-key-here'
```

### 2. Generate the image

Run the bundled script. The skill directory is at `~/.claude/skills/image-gen/`.

```bash
bash ~/.claude/skills/image-gen/scripts/generate-image.sh "<prompt>" "docs/images" "<filename>"
```

**Filename**: Derive a short, descriptive kebab-case filename from the prompt (no spaces, no special chars, max 60 chars). Always `.png`.

**Model override**: Set `GEMINI_MODEL` env var to switch models. Options:
- `gemini-2.5-flash-image` (default) — fast, high-volume
- `gemini-3-pro-image-preview` — higher fidelity, better text rendering

### 3. Report result

After generation, tell the user:
- The file path where the image was saved
- The file size
- Suggest they can reference it in markdown: `![description](docs/images/filename.png)`

### 4. Handle errors

- **No API key**: Tell user to set `GEMINI_API_KEY`
- **API error**: Show the error message from the response
- **No image in response**: The model may have refused (safety filters). Show any text response and suggest rephrasing the prompt
- **Missing tools**: `curl`, `jq`, and `base64` are required
