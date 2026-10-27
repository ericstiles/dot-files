#!/usr/bin/env bats
# Tests for notify-human.sh, the Claude Code Notification hook.

load test_helper

setup() {
  setup_sandbox
  SCRIPT="$HOOKS_DIR/notify-human.sh"
}

run_hook() {
  local fixture_name=$1 cwd=${2:-}
  run "$SCRIPT" <<<"$(fixture "$fixture_name" "$cwd")"
}

@test "permission prompt inside tmux names the repo and targets the tmux pane" {
  export TMUX_PANE=%3
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  assert_arg -title "Claude · myrepo"
  assert_arg -subtitle "needs permission"
  assert_arg -message "Claude needs your permission to use Bash"
  assert_arg -group "claude-sess-1"
  [[ "$output" == *"--tmux-pane %3"* ]]
  [[ "$output" == *"tmux 1:0.0"* ]]
}

@test "idle prompt outside tmux targets the WezTerm pane" {
  export WEZTERM_PANE=17
  run_hook idle_prompt
  [ "$status" -eq 0 ]
  assert_arg -subtitle "is idle"
  [[ "$output" == *"--wezterm-pane 17"* ]]
}

@test "elicitation dialog is described as a question" {
  run_hook elicitation_dialog
  [ "$status" -eq 0 ]
  assert_arg -subtitle "has a question"
}

@test "missing cwd falls back to unknown repo" {
  run_hook missing_cwd
  [ "$status" -eq 0 ]
  assert_arg -title "Claude · unknown"
}

@test "git branch is appended to the title when cwd is a repo" {
  local repo="$SANDBOX/work/branchy"
  mkdir -p "$repo"
  git -C "$repo" init -q -b feature-x
  run_hook permission_prompt "$repo"
  [ "$status" -eq 0 ]
  assert_arg -title "Claude · branchy (feature-x)"
}

@test "malformed JSON exits 0, sends nothing, and logs it" {
  run_hook malformed
  [ "$status" -eq 0 ]
  refute_line_prefix "terminal-notifier"
  grep -q "invalid-json" "$NOTIFY_LOG_FILE"
}

@test "long messages are truncated to 200 characters" {
  run_hook long_message
  [ "$status" -eq 0 ]
  local msg
  msg=$(awk 'prev=="-message"{print; exit} {prev=$0}' <<<"$output")
  [ "${#msg}" -eq 200 ]
}

@test "repeat of same session and type inside the window is throttled" {
  run_hook permission_prompt
  [[ "$output" == *"terminal-notifier"* ]]
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  refute_line_prefix "terminal-notifier"
  grep -q "throttled" "$NOTIFY_LOG_FILE"
}

@test "a different type for the same session is not throttled" {
  run_hook permission_prompt
  run_hook idle_prompt
  [[ "$output" == *"terminal-notifier"* ]]
}

@test "throttle window of 0 disables throttling" {
  export NOTIFY_THROTTLE_SECONDS=0
  run_hook permission_prompt
  run_hook permission_prompt
  [[ "$output" == *"terminal-notifier"* ]]
}

@test "MUTE file silences all notifications" {
  mkdir -p "$NOTIFY_STATE_DIR"
  touch "$NOTIFY_STATE_DIR/MUTE"
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  refute_line_prefix "terminal-notifier"
  grep -q "muted" "$NOTIFY_LOG_FILE"
}

@test "unsafe session id is not used as a file name or group" {
  run_hook bad_session_id
  [ "$status" -eq 0 ]
  [[ "$output" != *"../"* ]]
  [ -z "$(find "$SANDBOX" -name 'evil*')" ]
}

@test "unsafe TMUX_PANE is ignored" {
  export TMUX_PANE='%3; rm -rf ~'
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  [[ "$output" != *"--tmux-pane"* ]]
}

@test "every event is appended to the log" {
  run_hook permission_prompt
  grep -q $'permission_prompt\tmyrepo\tsess-1\tsent' "$NOTIFY_LOG_FILE"
}

@test "live mode: terminal-notifier failure is logged and falls back to osascript" {
  export NOTIFY_DRY_RUN=0 STUB_TN_EXIT=3
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  grep -q "^terminal-notifier -title" "$STUB_LOG"
  grep -q "^osascript -e display notification" "$STUB_LOG"
  grep -q "terminal-notifier-failed exit=3" "$NOTIFY_LOG_FILE"
}

@test "live mode: successful terminal-notifier does not also call osascript" {
  export NOTIFY_DRY_RUN=0
  run_hook permission_prompt
  grep -q "^terminal-notifier -title" "$STUB_LOG"
  ! grep -q "^osascript" "$STUB_LOG"
}

@test "no ntfy push without a configured topic" {
  run_hook permission_prompt
  refute_line_prefix "curl"
}

@test "ntfy push uses the topic from the env file with high priority for permission" {
  echo "NTFY_TOPIC=my_secret-topic42" > "$NOTIFY_ENV_FILE"
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  [[ "$output" == *"https://ntfy.sh/my_secret-topic42"* ]]
  assert_arg -H "Priority: high"
  assert_arg -H "Title: Claude - myrepo: needs permission"
}

@test "ntfy push for idle uses low priority" {
  echo "NTFY_TOPIC=my_secret-topic42" > "$NOTIFY_ENV_FILE"
  run_hook idle_prompt
  assert_arg -H "Priority: low"
}

@test "invalid ntfy topic is rejected and logged" {
  echo "NTFY_TOPIC=../../admin" > "$NOTIFY_ENV_FILE"
  run_hook permission_prompt
  [ "$status" -eq 0 ]
  refute_line_prefix "curl"
  grep -q "invalid-ntfy-topic" "$NOTIFY_LOG_FILE"
}

@test "env file is parsed, not executed" {
  printf 'NTFY_TOPIC=ok_topic\ntouch %s/pwned\n' "$SANDBOX" > "$NOTIFY_ENV_FILE"
  run_hook permission_prompt
  [ ! -e "$SANDBOX/pwned" ]
  [[ "$output" == *"https://ntfy.sh/ok_topic"* ]]
}
