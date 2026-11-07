# Keep Mamba's interactive shell hook in chezmoi instead of letting
# `mamba shell init` create a separate ~/.zshrc outside ZDOTDIR.
_mamba_executable="${MAMBA_EXE:-}"
if [[ ! -x "$_mamba_executable" ]]; then
  _mamba_executable="${commands[mamba]:-}"
fi
if [[ ! -x "$_mamba_executable" && -n "${CONDA_EXE:-}" ]]; then
  _mamba_executable="${CONDA_EXE:A:h:h}/bin/mamba"
fi

if [[ -x "$_mamba_executable" ]]; then
  _mamba_root_prefix="${MAMBA_ROOT_PREFIX:-${_mamba_executable:A:h:h}}"
  export MAMBA_EXE="$_mamba_executable"
  export MAMBA_ROOT_PREFIX="$_mamba_root_prefix"

  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
  if (( $? == 0 )); then
    eval "$__mamba_setup"
  else
    alias mamba="$MAMBA_EXE"
  fi
  unset __mamba_setup
fi

unset _mamba_executable _mamba_root_prefix
