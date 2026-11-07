# Use the active installation instead of assuming a Homebrew Caskroom path.
_conda_executable="${CONDA_EXE:-}"
if [[ ! -x "$_conda_executable" ]]; then
  _conda_executable="${commands[conda]:-}"
fi

if [[ -x "$_conda_executable" ]]; then
  __conda_setup="$("$_conda_executable" shell.zsh hook 2>/dev/null)"
  if (( $? == 0 )); then
    eval "$__conda_setup"
  elif [[ -r "${_conda_executable:A:h:h}/etc/profile.d/conda.sh" ]]; then
    source "${_conda_executable:A:h:h}/etc/profile.d/conda.sh"
  fi
fi

unset _conda_executable __conda_setup
