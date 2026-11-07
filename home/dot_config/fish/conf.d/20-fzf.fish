status is-interactive; or return

if command -q fzf
    fzf --fish | source
end
