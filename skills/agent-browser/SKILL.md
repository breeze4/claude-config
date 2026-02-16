---
name: agent-browser
description: Browser automation using the agent-browser CLI tool. Use for web testing, form filling, screenshot capture, and page interactions via snapshots and element refs.
allowed-tools: Bash, Read
---

# Browser Automation with agent-browser

## Quick start

```bash
agent-browser open <url>        # Navigate to page
agent-browser snapshot -i       # Get interactive elements with refs
agent-browser click @e1         # Click element by ref
agent-browser fill @e2 "text"   # Fill input by ref
agent-browser close             # Close browser
```

## Core workflow

1. Navigate: `agent-browser open <url>`
2. Snapshot: `agent-browser snapshot -i` (returns elements with refs like `@e1`, `@e2`)
3. Interact using refs from the snapshot
4. Re-snapshot after navigation or significant DOM changes

## Commands

### Navigation
```bash
agent-browser open <url>      # Navigate to URL (aliases: goto, navigate)
agent-browser back            # Go back
agent-browser forward         # Go forward
agent-browser reload          # Reload page
agent-browser close           # Close browser (aliases: quit, exit)
```

### Snapshot (page analysis)
```bash
agent-browser snapshot        # Full accessibility tree
agent-browser snapshot -i     # Interactive elements only (recommended)
agent-browser snapshot -C     # Include cursor-interactive elements
agent-browser snapshot -c     # Compact output
agent-browser snapshot -d 3   # Limit depth to 3
agent-browser snapshot -s "div.main"  # Scope to CSS selector
```

### Interactions (use @refs from snapshot)
```bash
agent-browser click @e1           # Click
agent-browser dblclick @e1        # Double-click
agent-browser fill @e2 "text"     # Clear and type
agent-browser type @e2 "text"     # Type without clearing
agent-browser press Enter         # Press key
agent-browser press Control+a     # Key combination
agent-browser keydown Shift       # Hold key down
agent-browser keyup Shift         # Release key
agent-browser hover @e1           # Hover
agent-browser focus @e1           # Focus element
agent-browser check @e1           # Check checkbox
agent-browser uncheck @e1         # Uncheck checkbox
agent-browser select @e1 "value"  # Select dropdown
agent-browser scroll down 500     # Scroll page
agent-browser scrollintoview @e1  # Scroll element into view
agent-browser drag @e1 @e2        # Drag and drop
agent-browser upload @e1 file.pdf # Upload files
```

### Get information
```bash
agent-browser get text @e1        # Get element text
agent-browser get html @e1        # Get innerHTML
agent-browser get value @e1       # Get input value
agent-browser get attr @e1 href   # Get attribute value
agent-browser get title           # Get page title
agent-browser get url             # Get current URL
agent-browser get count @e1       # Count matching elements
agent-browser get box @e1         # Get bounding box coordinates
```

### State checks
```bash
agent-browser is visible @e1      # Check visibility
agent-browser is enabled @e1      # Check if enabled
agent-browser is checked @e1      # Check if checked
```

### Screenshots & output
```bash
agent-browser screenshot          # Screenshot to stdout
agent-browser screenshot path.png # Save to file
agent-browser screenshot --full   # Full page
agent-browser pdf report.pdf      # Save page as PDF
```

### Wait
```bash
agent-browser wait @e1                     # Wait for element
agent-browser wait 2000                    # Wait milliseconds
agent-browser wait --text "Success"        # Wait for text
agent-browser wait --url "**/pattern"      # Wait for URL pattern
agent-browser wait --load networkidle      # Wait for network idle
agent-browser wait --fn "document.ready"   # Wait for JS condition
```

### JavaScript execution
```bash
agent-browser eval "document.title"        # Run JS and get result
agent-browser eval -b <base64>             # Base64-encoded JS
echo "script" | agent-browser eval --stdin # Piped JS input
```

### Semantic locators (alternative to refs)
```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@test.com"
agent-browser find placeholder "Search..." fill "query"
agent-browser find testid "submit-btn" click
agent-browser find first ".item" click
agent-browser find nth 2 ".item" click
```

### Tabs & windows
```bash
agent-browser tab                 # List open tabs
agent-browser tab new             # Open new tab
agent-browser tab new <url>       # Open new tab with URL
agent-browser tab 2               # Switch to tab 2
agent-browser tab close           # Close current tab
agent-browser window new          # Open new window
```

### Frames
```bash
agent-browser frame @e1           # Switch to iframe
agent-browser frame main          # Return to main frame
```

### Dialog handling
```bash
agent-browser dialog accept       # Accept dialog
agent-browser dialog accept "yes" # Accept with prompt text
agent-browser dialog dismiss      # Dismiss dialog
```

### Cookie & storage management
```bash
agent-browser cookies                          # Get all cookies
agent-browser cookies set name value           # Set cookie
agent-browser cookies clear                    # Clear all cookies
agent-browser storage local                    # Get all localStorage
agent-browser storage local set key value      # Set localStorage
agent-browser storage local clear              # Clear localStorage
agent-browser storage session                  # Get sessionStorage
```

### Network interception
```bash
agent-browser network route "**/api/*" --body '{"mock":true}'  # Mock response
agent-browser network route "**/ads/*" --abort                 # Block requests
agent-browser network unroute                                  # Remove all routes
agent-browser network requests                                 # View tracked requests
agent-browser network requests --filter "api"                  # Filter requests
```

### Browser settings
```bash
agent-browser set viewport 1280 720    # Set viewport size
agent-browser set device "iPhone 14"   # Emulate device
agent-browser set media dark           # Dark mode
agent-browser set offline on           # Offline mode
agent-browser set geo 37.7 -122.4      # Geolocation
agent-browser set headers '{"X-Key":"val"}'  # HTTP headers
agent-browser set credentials user pass      # HTTP basic auth
```

## Example: Form submission

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# Output shows: textbox "Email" [ref=e1], textbox "Password" [ref=e2], button "Submit" [ref=e3]

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Check result
```

## Example: Authentication with saved state

```bash
# Login once
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "username"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json

# Later sessions: load saved state
agent-browser state load auth.json
agent-browser open https://app.example.com/dashboard

# Manage saved states
agent-browser state list
agent-browser state show auth.json
agent-browser state clear --all
```

## Sessions (parallel browsers)

```bash
agent-browser --session test1 open site-a.com
agent-browser --session test2 open site-b.com
# Each session maintains its own browser instance
```

## Connection options

```bash
agent-browser --cdp 9222 open <url>       # Connect via CDP port
agent-browser --cdp ws://host:9222 <cmd>  # Connect to remote CDP
agent-browser --auto-connect <cmd>        # Auto-discover running Chrome
agent-browser --headed open <url>         # Show browser window
```

## JSON output (for parsing)

Add `--json` for machine-readable output:
```bash
agent-browser snapshot -i --json
agent-browser get text @e1 --json
```

## Debugging

```bash
agent-browser open example.com --headed  # Show browser window
agent-browser console                    # View console messages
agent-browser errors                     # View page errors
agent-browser highlight @e1              # Highlight element visually
agent-browser trace start                # Start recording trace
agent-browser trace stop trace.zip       # Stop and save trace
```

## Selector types

- `@e1`, `@e2` - Element refs from snapshot output (preferred)
- `#id`, `.class`, `div > button` - CSS selectors
- `text=Submit` - Text content matching
- `xpath=//button` - XPath expressions
