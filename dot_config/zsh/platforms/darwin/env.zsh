# macOS-only environment setup. Avoid launching commands in every zsh process.
export CP_HOME_DIR="$XDG_DATA_HOME/cocoapods"
export SHELL_SESSIONS_DISABLE=1

# Prefer the inherited Homebrew installation, then PATH, then standard prefixes.
_brew_path_prefix=""
if (( $+commands[brew] )); then
  _brew_path_prefix="${commands[brew]:a:h:h}"
fi

for _brew_prefix in "${HOMEBREW_PREFIX:-}" "$_brew_path_prefix" /opt/homebrew /usr/local; do
  [[ -n "$_brew_prefix" && -x "$_brew_prefix/bin/brew" ]] || continue
  export HOMEBREW_PREFIX="$_brew_prefix"

  # Never replace an inherited agent, especially an SSH-forwarded socket.
  if [[ -z "${SSH_AUTH_SOCK:-}" && -S "$HOMEBREW_PREFIX/var/run/yubikey-agent.sock" ]]; then
    export SSH_AUTH_SOCK="$HOMEBREW_PREFIX/var/run/yubikey-agent.sock"
  fi

  if [[ -d "$HOMEBREW_PREFIX/opt/rustup/bin" ]]; then
    path=("$HOME/.local/bin" "$HOMEBREW_PREFIX/opt/rustup/bin" $path)
  fi
  break
done

unset _brew_path_prefix _brew_prefix
