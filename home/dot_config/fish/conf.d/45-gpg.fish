status is-interactive; or return
command -q gpg; or return

# Without a graphical session (SSH, a console), pinentry falls back to its
# curses or tty prompt, which needs the terminal named here. No
# updatestartuptty: SSH goes through yubikey-agent, not gpg-agent.
tty -s; and set -gx GPG_TTY (tty)
