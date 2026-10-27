#!/usr/bin/env bash
# Brings a Claude session's pane to the front. Run by terminal-notifier when a
# notification from notify-human.sh is clicked.
#   claude-focus-pane.sh --tmux-pane %3     # session inside tmux
#   claude-focus-pane.sh --wezterm-pane 17  # session directly in a WezTerm tab
set -euo pipefail

readonly TERMINAL_BUNDLE_ID="${NOTIFY_TERMINAL_BUNDLE_ID:-com.github.wez.wezterm}"

# terminal-notifier runs us with launchd's minimal PATH; append (not prepend)
# so test stubs earlier on PATH still win.
PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"

usage_error() {
  echo "usage: $(basename "$0") [--tmux-pane %N | --wezterm-pane N]" >&2
  exit 2
}

# WezTerm pane whose tty is the tmux client currently showing this pane's session.
wezterm_pane_for_tmux() {
  local session tty
  session=$(tmux display -p -t "$1" '#S' 2>/dev/null) || return 0
  tty=$(tmux list-clients -t "$session" -F '#{client_tty}' 2>/dev/null | head -n 1)
  [[ -n "$tty" ]] || return 0
  wezterm cli list --format json 2>/dev/null \
    | jq -r --arg tty "$tty" 'map(select(.tty_name == $tty)) | .[0].pane_id // empty'
}

focus_tmux() {
  local wez
  tmux select-window -t "$1" || true
  tmux select-pane -t "$1" || true
  wez=$(wezterm_pane_for_tmux "$1")
  [[ -n "$wez" ]] && focus_wezterm "$wez"
  return 0
}

focus_wezterm() {
  wezterm cli activate-pane --pane-id "$1" || true
}

main() {
  case "${1:-}" in
    --tmux-pane)
      [[ "${2:-}" =~ ^%[0-9]+$ ]] || usage_error
      focus_tmux "$2" ;;
    --wezterm-pane)
      [[ "${2:-}" =~ ^[0-9]+$ ]] || usage_error
      focus_wezterm "$2" ;;
    "") ;;
    *) usage_error ;;
  esac
  open -b "$TERMINAL_BUNDLE_ID"
}

main "$@"
