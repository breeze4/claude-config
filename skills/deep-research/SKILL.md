---
name: deep-research
description: Submit deep research queries to Google Gemini via headed browser automation. Use when asked to do deep research, Google deep research, or Gemini deep research on a topic.
argument-hint: [research topic]
allowed-tools: AskUserQuestion, Bash, Read
user_invocable: true
---

# Deep Research via Gemini

Submit deep research queries to Google Gemini's Deep Research feature using headed browser automation.

## Process

### Phase 1: Clarify the Research Request

Read the user's topic from `<topic>` tags.

Before composing the prompt, evaluate whether clarification is needed. Ask 1-2 targeted questions using AskUserQuestion ONLY if genuine ambiguity exists:

- What specific aspects or angles should the research focus on?
- What depth is needed? (broad survey vs. deep dive on specific sub-topics)
- Any particular time periods, geographies, or perspectives to prioritize?
- What output structure is preferred? (comparative, chronological, pros/cons)

If the topic is already specific and well-scoped, skip clarification entirely and go straight to prompt composition.

### Phase 2: Compose the Research Prompt

Craft a detailed deep research prompt that:

- States the core research question clearly and unambiguously
- Specifies scope boundaries (what to include and exclude)
- Lists 3-5 specific sub-questions or angles to investigate
- Requests structured output with clear sections
- Includes any constraints from clarification

**Show the composed prompt to the user** and get approval before proceeding. Use AskUserQuestion with the full prompt text and ask if they want to proceed or revise.

### Phase 3: Submit via Gemini UI

Use agent-browser in **headed** mode (`--headed` flag on every command) to submit the query.

**CRITICAL**: Use `--headed` on EVERY agent-browser command, not just the first one. The headed flag is per-command, not persistent.

#### Step 1: Navigate to Gemini

```bash
agent-browser --headed open "https://gemini.google.com/app"
```

Wait for page load:
```bash
agent-browser --headed wait --load networkidle
```

#### Step 2: Check login state

```bash
agent-browser --headed snapshot -i
```

Inspect the snapshot output:
- If you see sign-in / login elements, tell the user: "Please log in to your Google account in the browser window. Let me know when you're done." Use AskUserQuestion to wait.
- If you see the Gemini chat interface (text input, model selector), proceed.

#### Step 3: Select Deep Research mode

```bash
agent-browser --headed snapshot -i
```

Look for a model/mode selector. Gemini typically has a dropdown or button to switch between models (e.g., "Gemini", "Deep Research", etc.). The exact UI may vary:

1. Look for a model selector dropdown, chip, or button near the top of the page or near the input area
2. Click it to reveal options
3. Look for "Deep Research" in the options and click it

If you can't find a model selector, try looking for a "Research" or "Deep Research" button/tab. Take a screenshot if stuck:
```bash
agent-browser --headed screenshot /tmp/gemini-ui.png
```
Then read the screenshot and describe what you see.

#### Step 4: Enter the prompt

After selecting Deep Research mode:

```bash
agent-browser --headed snapshot -i
```

Find the main text input area (usually a textbox or contenteditable div). Enter the composed prompt:

```bash
agent-browser --headed fill @eN "the composed prompt text here"
```

Or if the input is a contenteditable element, use `type` or `click` + `type`:
```bash
agent-browser --headed click @eN
agent-browser --headed type @eN "the composed prompt text here"
```

Then submit by pressing Enter or clicking the send button:
```bash
agent-browser --headed press Enter
```

#### Step 5: Approve the research plan

After submitting, Gemini Deep Research generates a research plan before starting. Wait for it to appear:

```bash
agent-browser --headed wait 8000
agent-browser --headed snapshot -i
```

Look for an approval/start button (e.g., "Start research", "Approve", or similar). Click it:

```bash
agent-browser --headed click @eN
```

If Gemini shows a research plan with an edit option, do NOT edit it - just approve and start.

#### Step 6: Confirm submission

Once the research has been kicked off (you'll see a progress indicator or "Researching..." state):

1. Tell the user the deep research query has been submitted successfully
2. Include a summary of what was submitted
3. Remind them to check the Gemini browser tab for results

**Do NOT wait for results. Do NOT close the browser.**

## Error Handling

- If the Gemini UI layout is unexpected, take a screenshot and show it to the user
- If login is required, pause and ask the user to log in manually
- If any step fails, report exactly what happened and ask the user how to proceed
- Always re-snapshot after every interaction (element refs are ephemeral)
- If the prompt is too long for the input field, try pasting via clipboard or splitting

## Notes

- Deep Research queries can take 5-30 minutes to complete in Gemini
- The browser must stay open for the research to continue
- Results will appear in the same Gemini conversation when done
- This skill only handles submission, not result retrieval

<topic>$ARGUMENTS</topic>
