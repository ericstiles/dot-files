# Shared setup for the notifier bats suites.

HOOKS_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
FIXTURES="$BATS_TEST_DIRNAME/fixtures"

setup_sandbox() {
  SANDBOX="$BATS_TEST_TMPDIR"
  export STUB_LOG="$SANDBOX/stub.log"
  export NOTIFY_STATE_DIR="$SANDBOX/state"
  export NOTIFY_LOG_FILE="$SANDBOX/notify.log"
  export NOTIFY_ENV_FILE="$SANDBOX/env"
  export NOTIFY_DRY_RUN=1
  : > "$STUB_LOG"

  local bin="$SANDBOX/bin"
  mkdir -p "$bin"
  for cmd in tmux wezterm open terminal-notifier osascript; do
    ln -sf "$BATS_TEST_DIRNAME/stubs/stub" "$bin/$cmd"
  done
  export PATH="$bin:$PATH"
  unset TMUX_PANE WEZTERM_PANE
}

# Render a fixture, substituting __CWD__ with $1.
fixture() {
  local name=$1 cwd=${2:-/Users/someone/repo/myrepo}
  sed "s|__CWD__|$cwd|g" "$FIXTURES/$name.json"
}

# Assert the dry-run output contains a flag immediately followed by a value.
assert_arg() {
  local flag=$1 value=$2
  if [[ "$output" != *$'\n'"$flag"$'\n'"$value"$'\n'* && "$output" != *$'\n'"$flag"$'\n'"$value" ]]; then
    echo "expected '$flag' '$value' in output:" >&2
    echo "$output" >&2
    return 1
  fi
}

refute_line_prefix() {
  if grep -q "^$1" <<<"$output"; then
    echo "did not expect a line starting with '$1':" >&2
    echo "$output" >&2
    return 1
  fi
}
