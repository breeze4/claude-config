# Idea: Background Process Notifications in Claude Code

## Problem

Can an external/background process report back into a running Claude Code session and show something to the user?

## Short Answer

No first-class "push a message into a running session" API exists. But there are several practical workarounds.

---

## Approaches (Ranked by Usefulness)

### 1. `claude --continue --print` — Best for "fire and forget" injection

A background process that finishes can spawn a new Claude Code invocation that resumes the current session:

```bash
claude --continue --print "Background build finished: $(cat /tmp/results.txt)"
```

This injects a new user turn into the most recent session non-interactively. Closest thing to true external-to-session push.

### 2. Hooks with File-Based State — Best for recurring context injection

A `UserPromptSubmit` hook runs on every prompt. The background process writes to a known file, and the hook reads it and injects via `additionalContext`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "cat /tmp/bg-status.json"
      }]
    }]
  }
}
```

Where the script outputs `{"additionalContext": "Build server reports: tests passing"}`.

**Limitation:** Only fires when the user submits a prompt, not proactively.

### 3. Async Hooks with `systemMessage` — Best for tool-triggered background work

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "/path/to/monitor.sh",
        "async": true,
        "timeout": 300
      }]
    }]
  }
}
```

The async hook runs in the background. When it finishes, its `systemMessage` output is delivered to Claude on the **next conversation turn**.

Useful but not instant — if the session is idle when the hook finishes, the message waits until the next user interaction.

### 4. `claude-commander` — Third-party socket injection

A Rust wrapper ([github.com/sstraus/claude-commander](https://github.com/sstraus/claude-commander)) that exposes a Unix socket at `/tmp/claudec-<SESSION_ID>.sock`:

```bash
echo '{"action":"send","text":"Background job done!"}' | nc -U /tmp/claudec-SESSION.sock
```

True programmatic injection, but unofficial, early-stage (v0.1.0), and no auth on the socket.

---

## What Doesn't Work

| Approach | Why |
|---|---|
| MCP server push | Request/response only, no unsolicited messages |
| Appending to session JSONL | Unsupported, will likely corrupt state |
| stdin injection into running session | Process owns its stdin, no external access |
| Native `run_in_background` notifications | Claude must poll via `TaskOutput`, no push |
| Named pipes / Unix sockets / signals | Not exposed as IPC entry points |

---

## Pragmatic Pattern

1. Background process writes results to a known file (e.g. `/tmp/bg-results.json`)
2. Either:
   - Use `claude --continue --print` to inject as a new turn, OR
   - Use a `UserPromptSubmit` hook to surface it as `additionalContext` on the next prompt

---

## Relevant GitHub Issues (All Closed / Not Planned)

- [#24983 — External event sources to trigger messages](https://github.com/anthropics/claude-code/issues/24983)
- [#15553 — Programmatic input submission in interactive mode](https://github.com/anthropics/claude-code/issues/15553)
- [#2929 — Programmatically drive instances](https://github.com/anthropics/claude-code/issues/2929)
- [#6854 — Non-blocking tasks / background bash notification](https://github.com/anthropics/claude-code/issues/6854)
- [#21191 — Notification when background bash completes](https://github.com/anthropics/claude-code/issues/21191)

---

## Hook Event Reference (for context)

Claude Code hooks fire on these lifecycle events:

- `SessionStart` — session/resume/compact start (stdout injected as context)
- `UserPromptSubmit` — before each prompt is processed
- `PreToolUse` / `PostToolUse` — around tool execution
- `PreCompact` — before context compaction
- `Notification` — when Claude generates a notification
- `Stop` / `SubagentStop` — when Claude or a subagent stops

Hooks can return:
- Plain stdout (injected as context for `SessionStart` and `UserPromptSubmit`)
- `{"additionalContext": "..."}` — injected into Claude's context
- `{"systemMessage": "..."}` — delivered as system message (async hooks)
- `{"decision": "block", "reason": "..."}` — block the action
