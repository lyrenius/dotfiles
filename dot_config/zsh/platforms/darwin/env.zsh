# macOS-only environment, sourced from .zshenv before PATH is assembled.
# Export variables only: .zshenv owns PATH. Avoid launching commands here,
# since every zsh process runs this file.
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
  break
done

unset _brew_path_prefix _brew_prefix
