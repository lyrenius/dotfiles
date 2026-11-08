# Without a graphical session (SSH, a console), pinentry falls back to its
# curses or tty prompt, which needs the terminal named here. No
# updatestartuptty: SSH goes through yubikey-agent, not gpg-agent.
if (( $+commands[gpg] )) && [[ -n "$TTY" ]]; then
  export GPG_TTY="$TTY"
fi
