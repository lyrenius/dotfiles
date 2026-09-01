if (( $+commands[conda] )); then
  __conda_setup="$(command conda shell.zsh hook 2>/dev/null)"
  if (( $? == 0 )); then
    eval "$__conda_setup"
  elif [[ -r "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]]; then
    source "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
  fi
  unset __conda_setup
elif [[ -r "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]]; then
  source "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
fi
