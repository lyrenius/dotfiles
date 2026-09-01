#!/bin/sh

set -eu

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
stable_dir="$config_home/tmux/tmux-which-key"
plugin_root="$config_home/tmux/plugins"
plugin_dir="$plugin_root/tmux-which-key"
plugin_config="$plugin_dir/config.yaml"
generated_init="$plugin_dir/plugin/init.tmux"
repository=https://github.com/alexwforsythe/tmux-which-key.git

fail() {
    printf 'tmux-which-key setup: %s\n' "$*" >&2
    exit 1
}

for command_name in git python3; do
    command -v "$command_name" >/dev/null 2>&1 || fail "missing command: $command_name"
done

[ -f "$stable_dir/config.yaml" ] || fail "missing $stable_dir/config.yaml"
[ -f "$stable_dir/REVISION" ] || fail "missing $stable_dir/REVISION"

revision=$(tr -d '[:space:]' < "$stable_dir/REVISION")
case "$revision" in
    *[!0-9a-f]*|'') fail "REVISION must contain one Git commit SHA" ;;
esac

mkdir -p "$plugin_root"
if [ ! -d "$plugin_dir/.git" ]; then
    [ ! -e "$plugin_dir" ] || fail "$plugin_dir exists but is not a Git checkout"
    git clone "$repository" "$plugin_dir"
fi

git -C "$plugin_dir" diff --quiet || fail "plugin has modified tracked files"
git -C "$plugin_dir" diff --cached --quiet || fail "plugin has staged changes"

if ! git -C "$plugin_dir" cat-file -e "$revision^{commit}" 2>/dev/null; then
    git -C "$plugin_dir" fetch origin
fi
git -C "$plugin_dir" checkout --quiet --detach "$revision"
git -C "$plugin_dir" submodule update --init --recursive

if [ -e "$plugin_config" ] && [ ! -L "$plugin_config" ]; then
    if cmp -s "$stable_dir/config.yaml" "$plugin_config"; then
        rm -f "$plugin_config"
    else
        backup="$plugin_config.before-dotfiles-$(date +%Y%m%dT%H%M%S)"
        mv "$plugin_config" "$backup"
        printf 'Preserved previous plugin-local config: %s\n' "$backup"
    fi
fi

ln -sfn "$stable_dir/config.yaml" "$plugin_config"
python3 "$plugin_dir/plugin/build.py" "$stable_dir/config.yaml" "$generated_init"

grep -Fq 'set -g @wk_cfg_pos_x "R"' "$generated_init"
grep -Fq 'set -g @wk_cfg_pos_y "S"' "$generated_init"
grep -Fq '󰆍 tmux' "$generated_init"

if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$generated_init"
    printf 'Live tmux server reload: PASS\n'
else
    printf 'Live tmux server reload: SKIPPED (no active server)\n'
fi

printf 'TMUX_WHICH_KEY_REVISION=%s\n' "$(git -C "$plugin_dir" rev-parse HEAD)"
printf 'TMUX_WHICH_KEY_CONFIG=%s\n' "$stable_dir/config.yaml"
printf 'TMUX_WHICH_KEY_SETUP=PASS\n'
