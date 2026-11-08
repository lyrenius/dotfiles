# fish loads every conf.d/*.fish before this file: ours, plus system and package
# snippets in file-name order. Those may prepend to PATH, so put user wrappers
# back in front here, as .zprofile does after path_helper and Homebrew.
fish_add_path --global --prepend --move $HOME/.local/bin

status is-interactive; or return

# Greeting: fastfetch's system summary, as in CachyOS's fish config; none where
# fastfetch is not installed.
if command -q fastfetch
    function fish_greeting
        fastfetch
    end
else
    set -g fish_greeting
end

# Prompt: ~/.config/starship.toml.
if command -q starship
    # pure, a dependency of cachyos-fish-config, loads from vendor_conf.d
    # whatever this file says, and hooks _pure_prompt_new_line on every
    # fish_prompt event. starship replaces pure's prompt but not that hook,
    # which clears the line before each prompt and, once pure's own prompt has
    # been drawn in the session, adds a blank line to starship's. Erasing the
    # function also removes the hook.
    functions -q _pure_prompt_new_line; and functions --erase _pure_prompt_new_line
    starship init fish | source
end
