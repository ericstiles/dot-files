# Rust toolchain (rustup/cargo/rustc) — puts ~/.cargo/bin on PATH
. "$HOME/.cargo/env"

if [ -r "$HOME/repo/dot-files/zsh/.zsh_env" ]; then
  . "$HOME/repo/dot-files/zsh/.zsh_env"
fi
