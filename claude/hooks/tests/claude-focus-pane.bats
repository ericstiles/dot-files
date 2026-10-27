#!/usr/bin/env bats
# Tests for claude-focus-pane.sh, run when a notification is clicked.

load test_helper

setup() {
  setup_sandbox
  SCRIPT="$HOOKS_DIR/claude-focus-pane.sh"
}

@test "tmux pane: selects window and pane, then activates the WezTerm tab showing that session" {
  run "$SCRIPT" --tmux-pane %3
  [ "$status" -eq 0 ]
  grep -qx "tmux select-window -t %3" "$STUB_LOG"
  grep -qx "tmux select-pane -t %3" "$STUB_LOG"
  grep -qx "wezterm cli activate-pane --pane-id 3" "$STUB_LOG"
  grep -qx "open -b com.github.wez.wezterm" "$STUB_LOG"
}

@test "tmux session with no attached client still raises the terminal" {
  run "$SCRIPT" --tmux-pane %9
  [ "$status" -eq 0 ]
  ! grep -q "activate-pane" "$STUB_LOG"
  grep -qx "open -b com.github.wez.wezterm" "$STUB_LOG"
}

@test "wezterm pane: activates it directly" {
  run "$SCRIPT" --wezterm-pane 17
  [ "$status" -eq 0 ]
  grep -qx "wezterm cli activate-pane --pane-id 17" "$STUB_LOG"
  grep -qx "open -b com.github.wez.wezterm" "$STUB_LOG"
}

@test "no target just raises the terminal" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -qx "open -b com.github.wez.wezterm" "$STUB_LOG"
}

@test "malformed pane ids are rejected without running anything" {
  run "$SCRIPT" --tmux-pane '%3;rm'
  [ "$status" -eq 2 ]
  run "$SCRIPT" --wezterm-pane 'abc'
  [ "$status" -eq 2 ]
  [ ! -s "$STUB_LOG" ]
}
