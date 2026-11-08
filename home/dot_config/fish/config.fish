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
    starship init fish | source
end
