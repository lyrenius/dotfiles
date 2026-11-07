status is-interactive; or return

# Same aliases as .zshrc, each only when its tool is installed.
if command -q eza
    alias ls 'eza --icons=always --color=always'
    alias ll 'eza -lh --icons=always --color=always'
    alias la 'eza -lah --icons=always --color=always'
    alias tree 'eza --tree --icons=always'
end
command -q bat; and alias cat 'bat --style=plain'
command -q nvim; and alias vim nvim
