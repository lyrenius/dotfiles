# tmux-which-key configuration

This directory is the portable, user-owned source of truth for the custom
tmux-which-key menu.

- `config.yaml` contains the menu, key bindings, icons, Vira styling, and its
  lower-right placement.
- `../plugins.lock` pins tmux-which-key and all other tmux plugin commits.
- `setup.sh` reads that lock, installs or checks out the pinned revision, links
  the user-owned config into the plugin checkout, initializes its Python
  dependency, builds `plugin/init.tmux`, and reloads a running tmux server when
  available.

Do not edit `~/.config/tmux/plugins/tmux-which-key/config.yaml` directly. It is
a generated symlink into this directory and the entire `plugins/` directory is
intentionally excluded from dotfiles.

## New machine

After applying dotfiles and installing `git`, `python3`, and tmux, run:

```sh
~/.config/tmux/tmux-which-key/setup.sh
```

The script can clone tmux-which-key itself if TPM has not installed it yet.
Other tmux plugins remain managed by TPM.

## Intentional plugin update

Fetch the repository, choose and audit the desired commit, replace the SHA in
`~/.config/tmux/plugins.lock`, then run `setup.sh` again. Commit the changed lock
and any required menu changes to the dotfiles repository.
