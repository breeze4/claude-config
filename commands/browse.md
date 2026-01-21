---
description: Browser automation - navigate sites, fill forms, extract data, test web apps
allowed-tools: Bash, Read, Write
---

# Browse

Automate browser tasks using the `agent-browser` CLI.

## Getting Started

When invoked with a task, proceed directly to execution.

If no task provided:
```
I'll help you automate browser tasks - navigation, form filling, data extraction, or testing.

What would you like me to do?
- Navigate and extract: "Get the top 3 headlines from news.ycombinator.com"
- Fill a form: "Submit the contact form on example.com with test data"
- Test a flow: "Test the login flow on localhost:3000"
```

## Usage

```
/browse Navigate to Hacker News and summarize the top 3 stories
/browse Fill out the signup form on example.com with test data
/browse Test that the checkout flow works on localhost:8080
/browse Extract all product names and prices from example.com/products
```

## Execution

Use the `agent-browser` CLI following the snapshot-interact pattern:

### 1. Navigate
```bash
agent-browser open <url>
```

### 2. Analyze
```bash
agent-browser snapshot -i
```
This returns interactive elements with refs like `@e1`, `@e2`.

### 3. Interact
```bash
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser select @e3 "option"
```

### 4. Re-snapshot
After navigation or form submission, snapshot again to get updated refs.

### 5. Extract / Verify
```bash
agent-browser get text @e1
agent-browser get title
agent-browser screenshot result.png
```

### 6. Close
```bash
agent-browser close
```

## Example Session

User: `/browse Get the top 3 stories from Hacker News`

```bash
agent-browser open https://news.ycombinator.com
agent-browser snapshot -i
# Identify story title elements from snapshot
agent-browser get text @e1
agent-browser get text @e2
agent-browser get text @e3
agent-browser close
```

Report the extracted story titles to the user.

## Tips

- Always snapshot before interacting - refs are dynamic
- Use `wait --load networkidle` after form submissions
- Screenshot at key steps for verification
- Use `--json` when you need to parse output
- For authenticated flows, use `state save/load` to persist sessions
