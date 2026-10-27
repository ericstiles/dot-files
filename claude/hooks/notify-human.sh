#!/usr/bin/env bash
# Claude Code Notification hook: tells me which session (repo) needs me, and
# lets a click on the notification jump to its tmux / WezTerm pane.
# Optional phone push via ntfy.sh when NTFY_TOPIC is set in the env file.
#
# Reads the hook JSON on stdin. Must never break a Claude session, so every
# failure path logs and exits 0.
set -euo pipefail

readonly MESSAGE_MAX_CHARS=200
readonly THROTTLE_SECONDS="${NOTIFY_THROTTLE_SECONDS:-30}"
readonly STATE_DIR="${NOTIFY_STATE_DIR:-$HOME/.claude/state/notify}"
readonly LOG_FILE="${NOTIFY_LOG_FILE:-$HOME/.claude/logs/notify.log}"
readonly ENV_FILE="${NOTIFY_ENV_FILE:-$HOME/.config/claude-notify/env}"
readonly NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
readonly DRY_RUN="${NOTIFY_DRY_RUN:-0}"
readonly SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
readonly FOCUS_SCRIPT="$SCRIPT_DIR/claude-focus-pane.sh"
readonly SAFE_ID_RE='^[A-Za-z0-9_-]{1,128}$'
readonly NTFY_TOPIC_RE='^[A-Za-z0-9_-]{1,64}$'

PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"

log() { # type repo session action
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$1" "$2" "$3" "$4" >> "$LOG_FILE"
}

on_error() {
  log "-" "-" "-" "error line $1" 2>/dev/null || true
  exit 0
}
trap 'on_error $LINENO' ERR

describe_type() {
  case "$1" in
    permission_prompt) echo "needs permission" ;;
    elicitation_dialog|elicitation_url_dialog) echo "has a question" ;;
    agent_needs_input) echo "needs input" ;;
    idle_prompt) echo "is idle" ;;
    agent_completed) echo "finished" ;;
    *) echo "$1" ;;
  esac
}

ntfy_priority() {
  case "$1" in
    permission_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input) echo "high" ;;
    *) echo "low" ;;
  esac
}

repo_title() { # cwd -> "repo" or "repo (branch)"
  local cwd=$1 repo branch
  [[ -z "$cwd" ]] && { echo "unknown"; return; }
  repo=$(basename "$cwd")
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || true)
  if [[ -n "$branch" ]]; then echo "$repo ($branch)"; else echo "$repo"; fi
}

# Echoes the focus-script arguments for the pane this session runs in.
focus_args() {
  if [[ "${TMUX_PANE:-}" =~ ^%[0-9]+$ ]]; then
    echo "--tmux-pane $TMUX_PANE"
  elif [[ "${WEZTERM_PANE:-}" =~ ^[0-9]+$ ]]; then
    echo "--wezterm-pane $WEZTERM_PANE"
  fi
}

tmux_target() {
  [[ "${TMUX_PANE:-}" =~ ^%[0-9]+$ ]] || return 0
  tmux display -p -t "$TMUX_PANE" '#S:#I.#P' 2>/dev/null || true
}

is_throttled() { # session type
  [[ "$THROTTLE_SECONDS" -le 0 ]] && return 1
  local stamp="$STATE_DIR/last-$1-$2" now last
  now=$(date +%s)
  if [[ -f "$stamp" ]]; then
    last=$(cat "$stamp")
    (( now - last < THROTTLE_SECONDS )) && return 0
  fi
  mkdir -p "$STATE_DIR"
  echo "$now" > "$stamp"
  return 1
}

# Parse NTFY_TOPIC out of the env file without sourcing it.
read_ntfy_topic() {
  [[ -f "$ENV_FILE" ]] || return 0
  sed -n 's/^NTFY_TOPIC=//p' "$ENV_FILE" | tail -n 1 | tr -d "\"' \r"
}

run_or_print() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\n' "$@"
  else
    "$@" >/dev/null 2>&1 || true
  fi
}

send_osascript() { # title subtitle message
  run_or_print osascript -e "display notification \"${3//\"/}\" with title \"${1//\"/}\" subtitle \"${2//\"/}\""
}

# Echoes a failure note for the log when terminal-notifier could not deliver
# (e.g. exit 3: notifications not allowed) and osascript was used instead.
send_desktop() { # title subtitle message group focus
  local args=(-title "$1" -subtitle "$2" -message "$3" -group "$4") rc=0
  [[ -n "$5" ]] && args+=(-execute "'$FOCUS_SCRIPT' $5")
  if ! command -v terminal-notifier >/dev/null 2>&1; then
    send_osascript "$1" "$2" "$3"
  elif [[ "$DRY_RUN" == "1" ]]; then
    run_or_print terminal-notifier "${args[@]}"
  else
    terminal-notifier "${args[@]}" >/dev/null 2>&1 || rc=$?
    if [[ "$rc" -ne 0 ]]; then
      send_osascript "$1" "$2" "$3"
      echo " terminal-notifier-failed exit=$rc"
    fi
  fi
}

send_ntfy() { # topic title message priority
  local cmd=(curl -fsS -m 5 -H "Title: $2" -H "Priority: $4" -H "Tags: robot" -d "$3" "$NTFY_SERVER/$1")
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '%s\n' "${cmd[@]}"
  else
    ("${cmd[@]}" >/dev/null 2>>"$LOG_FILE" &)
  fi
}

main() {
  local input type message cwd session repo title subtitle focus target topic note
  input=$(cat)
  if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$input"; then
    log "-" "-" "-" "invalid-json"
    return 0
  fi
  type=$(jq -r '.notification_type // "unknown"' <<<"$input")
  message=$(jq -r '.message // "Needs your attention"' <<<"$input")
  cwd=$(jq -r '.cwd // ""' <<<"$input")
  session=$(jq -r '.session_id // ""' <<<"$input")
  [[ "$session" =~ $SAFE_ID_RE ]] || session="invalid"
  [[ "$type" =~ $SAFE_ID_RE ]] || type="unknown"
  repo=$(basename "${cwd:-unknown}")

  if [[ -e "$STATE_DIR/MUTE" ]]; then log "$type" "$repo" "$session" "muted"; return 0; fi
  if is_throttled "$session" "$type"; then log "$type" "$repo" "$session" "throttled"; return 0; fi

  title="Claude · $(repo_title "$cwd")"
  subtitle=$(describe_type "$type")
  message=${message:0:$MESSAGE_MAX_CHARS}
  focus=$(focus_args)
  target=$(tmux_target)
  [[ "$DRY_RUN" == "1" && -n "$target" ]] && echo "target: tmux $target"

  note=$(send_desktop "$title" "$subtitle" "$message" "claude-$session" "$focus")
  [[ "$DRY_RUN" == "1" ]] && { printf '%s\n' "$note"; note=""; }

  topic=$(read_ntfy_topic)
  if [[ -n "$topic" ]]; then
    if [[ "$topic" =~ $NTFY_TOPIC_RE ]]; then
      send_ntfy "$topic" "Claude - $repo: $subtitle" "$message" "$(ntfy_priority "$type")"
    else
      log "$type" "$repo" "$session" "invalid-ntfy-topic"
    fi
  fi
  log "$type" "$repo" "$session" "sent${target:+ tmux=$target}${note}"
}

main
exit 0
