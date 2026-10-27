# Claude Code "needs me" notifier

A global Claude Code `Notification` hook. When any Claude session in any repo is blocked on you, a macOS notification shows the repo, the branch and what the session is asking. Clicking it jumps to that session's tmux pane or WezTerm tab. It can also push the alert to your phone through ntfy.sh.

## Files

| File | Purpose |
|---|---|
| `notify-human.sh` | The hook. Reads the hook JSON on stdin and sends the notification. |
| `claude-focus-pane.sh` | Runs when a notification is clicked. Selects the tmux pane, finds the WezTerm tab whose tty is that tmux client, activates it, and raises WezTerm. |
| `tests/` | bats suites. Run `bats claude/hooks/tests/`. |

`setup.sh` symlinks both scripts into `~/.claude/hooks/`. `~/.claude/settings.json` is not managed by this repo. The hook entry is added to it in place:

```json
"Notification": [
  { "matcher": "permission_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input|idle_prompt",
    "hooks": [{ "type": "command", "command": "$HOME/.claude/hooks/notify-human.sh", "timeout": 5 }] }
]
```

## What fires when

These timings come from Claude Code's docs. In a terminal, the first three only fire once you seem to be away.

| Type | Subtitle | When |
|---|---|---|
| `permission_prompt` | needs permission | A tool approval has waited about 6s with no typing |
| `elicitation_dialog`, `elicitation_url_dialog` | has a question | An MCP form or URL request has waited about 6s |
| `agent_needs_input` | needs input | A background session waits while `claude agents` is open |
| `idle_prompt` | is idle | About 60s after Claude finished, if you haven't typed |

Alerts from the same session replace each other in Notification Center, because each session uses its own `-group`. A repeat of the same session and type within 30s is dropped (`NOTIFY_THROTTLE_SECONDS`).

## Phone push (ntfy)

1. Install the ntfy app (iOS or Android) and subscribe to a topic name nobody could guess, for example the output of `openssl rand -hex 12`. Anyone who knows the topic can read and send your alerts.
2. Store the topic outside this public repo:
   ```sh
   mkdir -p ~/.config/claude-notify
   echo "NTFY_TOPIC=<your-topic>" > ~/.config/claude-notify/env
   chmod 600 ~/.config/claude-notify/env
   ```
   The file is parsed, never sourced. Topics must match `[A-Za-z0-9_-]{1,64}`. Questions and permission prompts are sent with high priority, and idle alerts with low priority. To use a self-hosted server, set `NTFY_SERVER`.

## Mute, logs, removal

- Mute with `touch ~/.claude/state/notify/MUTE`. Unmute with `rm ~/.claude/state/notify/MUTE`.
- Each event is appended to `~/.claude/logs/notify.log` as `time  type  repo  session  action`. The action is `sent`, `throttled`, `muted`, `invalid-json`, `invalid-ntfy-topic`, or `error line N`.
- To remove the notifier, delete the `Notification` entry above from `~/.claude/settings.json`, then `rm ~/.claude/hooks/notify-human.sh ~/.claude/hooks/claude-focus-pane.sh`.

## Troubleshooting

- No banner: open System Settings → Notifications → terminal-notifier and allow alerts. Test with `terminal-notifier -message hi`.
- Clicking does nothing: run `~/.claude/hooks/claude-focus-pane.sh --tmux-pane %0` by hand. The script assumes WezTerm (`NOTIFY_TERMINAL_BUNDLE_ID` overrides it).
- Dry run: `NOTIFY_DRY_RUN=1 ~/.claude/hooks/notify-human.sh < claude/hooks/tests/fixtures/permission_prompt.json` prints the commands instead of running them.
