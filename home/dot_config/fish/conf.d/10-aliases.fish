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

# Man pages rendered by bat, the counterpart of zsh's colored-man-pages plugin.
# MANROFFOPT=-c keeps groff's output in a form col -bx can strip.
if command -q bat
    set -gx MANROFFOPT -c
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# Kept from CachyOS's fish config.
alias tarnow 'tar -acf'
command -q wget; and alias wget 'wget -c'
command -q nc; and alias tb 'nc termbin.com 9999'
