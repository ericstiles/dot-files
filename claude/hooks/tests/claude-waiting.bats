#!/usr/bin/env bats
# Tests for claude-waiting.sh: the "who is waiting on me" list behind the tmux
# status bar segment.

load test_helper

setup() {
  setup_sandbox
  SCRIPT="$HOOKS_DIR/claude-waiting.sh"
}

clear_json() { printf '{"session_id":"%s","hook_event_name":"UserPromptSubmit"}' "$1"; }

@test "status is empty when nobody is waiting" {
  run "$SCRIPT" status
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "blocked sessions are listed by repo" {
  "$SCRIPT" mark s1 OptiGate permission_prompt
  "$SCRIPT" mark s2 meal-prompt elicitation_dialog
  run "$SCRIPT" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"2 blocked: meal-prompt, OptiGate"* || "$output" == *"2 blocked: OptiGate, meal-prompt"* ]]
}

@test "idle sessions are only counted" {
  "$SCRIPT" mark s1 OptiGate permission_prompt
  "$SCRIPT" mark s3 talk-to-pi idle_prompt
  "$SCRIPT" mark s4 hac-nisd idle_prompt
  run "$SCRIPT" status
  [[ "$output" == *"1 blocked: OptiGate"* ]]
  [[ "$output" == *"2 idle"* ]]
  [[ "$output" != *"talk-to-pi"* ]]
}

@test "only idle sessions shows just the idle count" {
  "$SCRIPT" mark s3 talk-to-pi idle_prompt
  run "$SCRIPT" status
  [[ "$output" == *"1 idle"* ]]
  [[ "$output" != *"blocked"* ]]
}

@test "a later mark for the same session replaces the earlier one" {
  "$SCRIPT" mark s1 OptiGate idle_prompt
  "$SCRIPT" mark s1 OptiGate permission_prompt
  run "$SCRIPT" status
  [[ "$output" == *"1 blocked: OptiGate"* ]]
  [[ "$output" != *"idle"* ]]
}

@test "clear reads the hook JSON and removes that session" {
  "$SCRIPT" mark s1 OptiGate permission_prompt
  "$SCRIPT" mark s2 meal-prompt permission_prompt
  run "$SCRIPT" clear <<<"$(clear_json s1)"
  [ "$status" -eq 0 ]
  run "$SCRIPT" status
  [[ "$output" == *"1 blocked: meal-prompt"* ]]
}

@test "clear refreshes tmux only when something was removed" {
  run "$SCRIPT" clear <<<"$(clear_json nobody)"
  ! grep -q "refresh-client" "$STUB_LOG"
  "$SCRIPT" mark s1 OptiGate permission_prompt
  : > "$STUB_LOG"
  run "$SCRIPT" clear <<<"$(clear_json s1)"
  grep -q "tmux list-clients" "$STUB_LOG"
}

@test "clear with malformed or missing input exits 0" {
  run "$SCRIPT" clear <<<"not json"
  [ "$status" -eq 0 ]
  run "$SCRIPT" clear <<<'{"hook_event_name":"Stop"}'
  [ "$status" -eq 0 ]
}

@test "unsafe session ids are refused" {
  run "$SCRIPT" mark "../../evil" OptiGate permission_prompt
  [ "$status" -eq 0 ]
  [ -z "$(find "$SANDBOX" -name 'evil*')" ]
  run "$SCRIPT" clear <<<"$(clear_json '../../state')"
  [ "$status" -eq 0 ]
  [ -d "$NOTIFY_STATE_DIR" ] || true
}

@test "stale entries are dropped from status" {
  export NOTIFY_WAITING_STALE_SECONDS=1
  "$SCRIPT" mark s1 OptiGate permission_prompt
  sleep 2
  run "$SCRIPT" status
  [ -z "$output" ]
  [ -z "$(ls "$NOTIFY_STATE_DIR/waiting")" ]
}

@test "repo names with tmux format characters are neutralised" {
  "$SCRIPT" mark s1 '#(rm -rf ~)' permission_prompt
  run "$SCRIPT" status
  [[ "$output" != *"#("* ]]
}

@test "unknown subcommand fails with usage" {
  run "$SCRIPT" bogus
  [ "$status" -eq 2 ]
}
