# Dotfiles

This is the chezmoi source directory. Paths mirror the destination home
directory: `dot_config` becomes `~/.config`, and `private_Library` becomes
`~/Library`. Templates and restore scripts live in chezmoi's special directories.

## Shell layout

zsh reads `~/.zshenv` (`dot_zshenv`), which only points `ZDOTDIR` at
`~/.config/zsh`. Each file there has one phase:

| File | Runs in | Owns |
| --- | --- | --- |
| `dot_zshenv` | every zsh | XDG and tool homes, then PATH. The only place the configuration orders its own PATH entries. |
| `dot_zprofile` | login shells | platform login setup, mise shims, then moving `~/.local/bin` back to the front after macOS `path_helper`, Homebrew, and mise prepend theirs. |
| `dot_zshrc` | interactive shells | prompt, Oh My Zsh, aliases, then every `integrations/*.zsh` in file-name order. |
| `platforms/darwin/env.zsh` | every zsh on macOS | Homebrew prefix and the YubiKey agent fallback. Exports variables only, never PATH. |
| `platforms/darwin/profile.zsh` | login shells on macOS | Homebrew shellenv, OrbStack, and JetBrains Toolbox. |

To add a tool's interactive hook, add `integrations/NN-tool.zsh` that checks
for the tool itself; `.zshrc` does not need to change.

## tmux plugins

`dot_config/tmux/plugins.lock` is the only plugin list: one GitHub repository
and full commit SHA per line, in load order. The tmux restore script checks
each one out under `~/.config/tmux/plugins/`, and `load-plugins.sh` (run at the
end of `tmux.conf`) executes their `*.tmux` entry points the way TPM would.
There is no TPM, so nothing updates a plugin behind the lock.

To add or update a plugin, edit `plugins.lock` (and any `@option`s in
`tmux.conf.tmpl`), then `chezmoi apply`. The restore script reports checkouts
that are no longer in the lock; delete them by hand.

The tmux-which-key menu lives in `tmux-which-key/config.yaml.tmpl`. The restore
script links it into the plugin checkout and builds it once to catch errors;
the plugin rebuilds it whenever tmux loads.

## Neovim theme

`lua/vira/init.lua` builds the `vira-graphene` colorscheme from the variant
files in `lua/vira/variants/`, one per Vira variant; `:ViraTheme` switches
between them. Those JSON files are generated from the installed VS Code Vira
Theme extension; do not edit them by hand:

```sh
tools/vira-nvim.py --list              # variants the extension provides
tools/vira-nvim.py                     # regenerate every variant
```

`tools/` is repository tooling and is not deployed.

## Platform boundaries

- `.chezmoiignore.tmpl` excludes the entire `Library` tree, AeroSpace, and the
  Darwin shell directory on other operating systems.
- Ghostty supports both macOS and Linux; it is not treated as macOS-only.

An inherited `SSH_AUTH_SOCK` is preserved. The macOS YubiKey socket is selected
only when the variable is empty and that socket exists. Conda and Mamba use
their configured executables or commands on PATH instead of a fixed Caskroom
installation. An existing `MAMBA_ROOT_PREFIX` is preserved.

## Machine-specific choices

`.chezmoidata.toml` records shared defaults. Zsh management is explicit and does
not change with the `SHELL` environment variable. To override defaults on one
machine, merge the relevant settings into `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.features]
zsh = false

[data.restore]
tmux = false
yazi = false
neovim = false
```

Disabling a restore script keeps the application's configuration managed; it
only disables plugin installation and restoration. The default restore settings
remain enabled for the complete development environment.

## Applying changes

For configuration-only updates, inspect and apply without running restore scripts:

```sh
chezmoi diff --exclude=scripts
chezmoi apply --exclude=scripts
```

For a full restore, install the required applications first, inspect
`chezmoi diff`, then run `chezmoi apply`. Restore scripts require their tools to
be present and restore pinned plugin versions; they do not install system
packages, Oh My Zsh, or its prompt and plugins. Disable unneeded restore scripts
in the local configuration on machines with a smaller tool set.

Prefer `chezmoi edit` for managed files, or update this source directory and
inspect `chezmoi diff` before applying. Keep machine-local paths and choices out
of shared configuration unless they are guarded by a platform or capability check.
