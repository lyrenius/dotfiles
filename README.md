# Dotfiles

This repository is a chezmoi source directory. `.chezmoiroot` points chezmoi
at `home/`, so the repository root holds only files about the repository:

- `home/` mirrors the home directory: `home/dot_config` becomes `~/.config`,
  and `home/private_Library` becomes `~/Library`. chezmoi's own files
  (`.chezmoidata.toml`, `.chezmoiignore.tmpl`, `.chezmoiscripts/`, and so on)
  live there too.
- `tools/` holds repository tooling. It is outside `home/` and never deployed.
- `README.md` is this file.

## Shell layout

This applies where `features.zsh` is enabled (see Machine-specific choices).
zsh reads `~/.zshenv` (`home/dot_zshenv`), which only points `ZDOTDIR` at
`~/.config/zsh` (`home/dot_config/zsh/`). Each file there has one phase:

| File | Runs in | Owns |
| --- | --- | --- |
| `dot_zshenv` | every zsh | XDG and tool homes, then PATH. The only place the configuration orders its own PATH entries. On Arch, `/usr/lib/rustup/bin` (rustup's rust-analyzer proxy) goes after the system directories. |
| `dot_zprofile` | login shells | platform login setup, mise shims, then moving `~/.local/bin` back to the front after macOS `path_helper`, Homebrew, and mise prepend theirs. |
| `dot_zshrc` | interactive shells | prompt, Oh My Zsh, aliases, then every `integrations/*.zsh` in file-name order. |
| `platforms/darwin/env.zsh` | every zsh on macOS | Homebrew prefix and the YubiKey agent fallback. Exports variables only, never PATH. |
| `platforms/darwin/profile.zsh` | login shells on macOS | Homebrew shellenv, OrbStack, and JetBrains Toolbox. |

To add a tool's interactive hook, add `integrations/NN-tool.zsh` that checks
for the tool itself; `.zshrc` does not need to change.

## fish

Where `features.fish` is enabled, `home/dot_config/fish/` and the starship
prompt (`home/dot_config/starship.toml`) are deployed. fish reads every
`conf.d/*.fish` in file-name order, then `config.fish`:

| File | Runs in | Owns |
| --- | --- | --- |
| `conf.d/00-environment.fish` | every fish | the same environment as `.zshenv`: XDG and tool homes, `EDITOR`, `LANG`, PATH. On Arch, `/usr/lib/rustup/bin` goes after the system directories in every fish; Arch's own fish snippet adds it to login shells only. |
| `conf.d/10-aliases.fish` | interactive | the `.zshrc` aliases, each only when its tool is installed; bat as `MANPAGER`; `tarnow`, `wget -c`, `tb`. |
| `conf.d/15-shortcuts.fish` | interactive | `!!` and `!$` history expansion, and `..`, `...`, … as `cd ../`, `cd ../../`, …. |
| `conf.d/20-fzf.fish`, `30-zoxide.fish`, `80-mise.fish` … `95-mamba.fish` | interactive (mise also elsewhere, as shims) | tool hooks, as in zsh's `integrations/`. |
| `conf.d/40-done.fish` | interactive, where CachyOS ships done | notifications for long commands that finish in the background. |
| `conf.d/45-gpg.fish` | interactive, with gpg installed | `GPG_TTY`, as zsh's `integrations/45-gpg.zsh` (see Platform boundaries). |
| `conf.d/50-linux.fish` | interactive, deployed on Linux only | system and pacman abbreviations. |
| `functions/backup.fish` | when first called | `backup FILE...` copies each file to `FILE.bak`. |
| `config.fish` | interactive | the fastfetch greeting and the starship prompt. |

The prompt keeps the zsh layout (two lines, left frame, dotted gap, details on
the right) as plain colored text in the Vira Graphene palette, with three
icons: the OS logo, the git branch, and ✔/✘. The macOS-only zsh setup
(Homebrew, the YubiKey agent, OrbStack, JetBrains Toolbox) has no fish
counterpart yet.

### CachyOS

The `cachyos-fish-config` package gives each user a one-line
`~/.config/fish/config.fish` that sources
`/usr/share/cachyos-fish-config/cachyos-config.fish`. Deploying this
configuration replaces that line, so none of the CachyOS file runs any more. The
parts worth keeping are ported, abbreviations replacing aliases where the full
command (often with `sudo`) should be visible before it runs:

- the fastfetch greeting, in `config.fish`;
- done notifications, in `conf.d/40-done.fish`, which sources the package's copy
  with the same settings, as global variables instead of universal ones;
- bat man pages, `tarnow`, `wget -c`, and `tb`, in `conf.d/10-aliases.fish`;
- `!!`, `!$`, and the `..` family, in `conf.d/15-shortcuts.fish`;
- `jctl`, `psmem`, `hw`, `grubup`, and the pacman commands (`fixpacman`,
  `cleanup`, `gitpkg`, `big`, `rip`, `mirror`, `update`), in
  `conf.d/50-linux.fish`, each only when its tool is installed;
- `backup`, in `functions/backup.fish`.

Left out: its eza aliases (these match zsh's), its PATH entries and
`~/.fish_profile` (`00-environment.fish` owns the environment), its `history`
override (it hides fish's own `history` function and breaks `history clear` and
interactive `history delete`), `copy` (it calls a `trim-right` command that does
not exist), `untar` (gzip only; `tar -xf` detects the format), the `dir`,
`vdir`, `grep`, `fgrep`, and `egrep` color aliases, and `apt`/`apt-get`.

The package's dependencies still load on their own: fish-autopair, pkgfile's
command-not-found suggestions, and the pure prompt's `conf.d`. starship replaces
pure's prompt, but pure still sets its universal defaults and the window title.

The CachyOS file stored some universal variables, which outlive it. After the
first `chezmoi apply`, remove its done settings, then check `fish_user_paths`
for the entries its `fish_add_path` stored (erase them with
`set -eU fish_user_paths` if nothing else is there):

```fish
set -eU __done_min_cmd_duration __done_notification_urgency_level
set -S fish_user_paths
```

## Tool homes and GUI apps

`toolHomes` in `home/.chezmoidata.toml` lists the tools whose state moved under
`~/.local/share`, as `VARIABLE = "directory"`. `.zshenv` and fish's
`conf.d/00-environment.fish` export every entry.

GUI apps on macOS start from launchd and never read `.zshenv`. Names listed in
`launchd.env` are also set for them: the `com.lyre.environment` LaunchAgent runs
`launchctl setenv` at login, and on `chezmoi apply` the launchd-environment
script applies a change right away. Both are rendered from
`.chezmoitemplates/launchd-setenv.sh`, so each value is written once. Apps that
are already open keep their old environment until relaunched, and a name removed
from `launchd.env` is dropped at the next login.

To relocate another tool, add it to `toolHomes`; add it to `launchd.env` as well
if its GUI app needs it.

## tmux plugins

`home/dot_config/tmux/plugins.lock` is the only plugin list: one GitHub repository
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

## Colors

`palette` in `home/.chezmoidata.toml` holds the Vira Graphene colors used by
the tmux theme and status line, the tmux-which-key menu, the starship prompt,
and the restore scripts' output. Change a color there; `chezmoi apply`
re-renders those files and reloads a running tmux server. Because the restore
scripts embed the colors, a palette change also runs them once more. Neovim
takes its colors from the generated theme files instead (see Neovim theme).

## Neovim theme

In `home/dot_config/nvim/`, `lua/vira/init.lua` builds the `vira-graphene`
colorscheme from the variant files in `lua/vira/variants/`, one per Vira variant; `:ViraTheme` switches
between them. Those JSON files are generated from the installed VS Code Vira
Theme extension; do not edit them by hand:

```sh
tools/vira-nvim.py --list              # variants the extension provides
tools/vira-nvim.py                     # regenerate every variant
```

## Platform boundaries

- `.chezmoiignore.tmpl` excludes the entire `Library` tree, AeroSpace, and the
  Darwin shell directory on other operating systems, and fish's
  `conf.d/50-linux.fish` on every system but Linux.
- Ghostty supports both macOS and Linux; it is not treated as macOS-only.

An inherited `SSH_AUTH_SOCK` is preserved. The macOS YubiKey socket is selected
only when the variable is empty and that socket exists. Interactive shells with
gpg installed export `GPG_TTY` (zsh's `integrations/45-gpg.zsh`, fish's
`conf.d/45-gpg.fish`): without a graphical session, pinentry falls back to its
curses or tty prompt, which needs it. pinentry-mac ignores it. There is no
`gpg-connect-agent updatestartuptty`, because SSH authentication goes through
yubikey-agent rather than gpg-agent. Conda and Mamba use
their configured executables or commands on PATH instead of a fixed Caskroom
installation. An existing `MAMBA_ROOT_PREFIX` is preserved.

## Machine-specific choices

`home/.chezmoidata.toml` records shared defaults. Each machine overrides them
under `[data]` in `~/.config/chezmoi/chezmoi.toml`.

Shell configuration is opt-in, because each machine picks its own shell. The zsh
configuration (`~/.zshenv` and `~/.config/zsh/`) and the fish configuration
(`~/.config/fish/` and `~/.config/starship.toml`) are deployed only where they
are enabled, and neither follows the `SHELL` environment variable. On a machine
that uses zsh, or fish:

```toml
[data.features]
zsh = true    # or: fish = true
```

Turning it off later leaves the deployed files in place, but chezmoi stops
updating them.

Plugin restores are enabled by default. To skip some on a machine with a
smaller tool set:

```toml
[data.restore]
tmux = false
yazi = false
neovim = false
```

Disabling a restore script keeps the application's configuration managed; it
only disables plugin installation and restoration.

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

Prefer `chezmoi edit` for managed files, or update the files under `home/` and
inspect `chezmoi diff` before applying. Keep machine-local paths and choices out
of shared configuration unless they are guarded by a platform or capability check.
