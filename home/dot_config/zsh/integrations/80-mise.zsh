# Full activation for interactive shells (updates tools on directory change).
# Login shells already put mise shims on PATH in .zprofile.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
