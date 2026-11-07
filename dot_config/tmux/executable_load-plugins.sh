#!/bin/sh
# Run each pinned plugin's *.tmux entry points, in plugins.lock order.
#
# This is the loading half of TPM only. chezmoi's restore script installs
# the checkouts at the locked commits, so nothing here clones, updates, or
# binds install keys that could move a plugin away from its lock.

tmux_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd) || exit 1
lock_file="$tmux_dir/plugins.lock"
plugin_root="$tmux_dir/plugins"

[ -r "$lock_file" ] || exit 0

while read -r repository _; do
    case "$repository" in
        ''|'#'*) continue ;;
    esac
    for entry in "$plugin_root/${repository##*/}"/*.tmux; do
        [ -f "$entry" ] || continue
        # stdin is the lock file; keep plugins from reading it.
        "$entry" </dev/null >/dev/null 2>&1
    done
done < "$lock_file"
