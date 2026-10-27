#!/usr/bin/env bash
# Tracks which Claude sessions are waiting on me, for the tmux status bar.
#   claude-waiting.sh mark <session> <repo> <notification_type>   # from notify-human.sh
#   claude-waiting.sh clear      # hook: reads hook JSON on stdin, drops that session
#   claude-waiting.sh status     # tmux #(...) segment, e.g. "⚑ 2 blocked: a, b · 3 idle |"
# Hook paths must never break a Claude session, so mark/clear always exit 0.
set -euo pipefail

readonly STATE_DIR="${NOTIFY_STATE_DIR:-$HOME/.claude/state/notify}"
readonly WAITING_DIR="$STATE_DIR/waiting"
readonly STALE_SECONDS="${NOTIFY_WAITING_STALE_SECONDS:-28800}"
readonly SAFE_ID_RE='^[A-Za-z0-9_-]{1,128}$'
readonly BLOCKED_STYLE='#[fg=colour226,bold]'
readonly IDLE_STYLE='#[fg=colour245]'
readonly RESET_STYLE='#[default]'

PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"

usage_error() {
  echo "usage: $(basename "$0") mark <session> <repo> <type> | clear | status" >&2
  exit 2
}

# Keep repo names from injecting tmux formats (#[..], #(..)) into the status line.
sanitize() { printf '%s' "$1" | tr -c 'A-Za-z0-9._ -' '_'; }

refresh_tmux() {
  local client
  tmux list-clients -F '#{client_name}' 2>/dev/null | while read -r client; do
    tmux refresh-client -S -t "$client" 2>/dev/null || true
  done
}

mark() { # session repo type
  [[ "${1:-}" =~ $SAFE_ID_RE ]] || return 0
  mkdir -p "$WAITING_DIR"
  printf '%s\t%s\t%s\n' "$(sanitize "${2:-unknown}")" "$(sanitize "${3:-unknown}")" "$(date +%s)" \
    > "$WAITING_DIR/$1"
  refresh_tmux
}

clear_session() {
  local session
  session=$(jq -r '.session_id // ""' 2>/dev/null || true)
  [[ "$session" =~ $SAFE_ID_RE ]] || return 0
  [[ -f "$WAITING_DIR/$session" ]] || return 0
  rm -f "$WAITING_DIR/$session"
  refresh_tmux
}

status() {
  [[ -d "$WAITING_DIR" ]] || return 0
  local now file repo type stamp blocked=() idle=0
  now=$(date +%s)
  for file in "$WAITING_DIR"/*; do
    [[ -f "$file" ]] || continue
    IFS=$'\t' read -r repo type stamp < "$file" || continue
    if (( now - ${stamp:-0} > STALE_SECONDS )); then rm -f "$file"; continue; fi
    if [[ "$type" == "idle_prompt" ]]; then
      idle=$((idle + 1))
    else
      blocked+=("$repo")
    fi
  done
  local out=""
  if (( ${#blocked[@]} > 0 )); then
    local names
    names=$(printf '%s\n' "${blocked[@]}" | sort -f | paste -sd ',' - | sed 's/,/, /g')
    out="${BLOCKED_STYLE}⚑ ${#blocked[@]} blocked: ${names}${RESET_STYLE}"
  fi
  if (( idle > 0 )); then
    out="${out:+$out · }${IDLE_STYLE}${idle} idle${RESET_STYLE}"
  fi
  [[ -n "$out" ]] && printf '%s |\n' "$out"
  return 0
}

case "${1:-}" in
  mark) shift; mark "$@" || true ;;
  clear) clear_session || true ;;
  status) status ;;
  *) usage_error ;;
esac
exit 0
