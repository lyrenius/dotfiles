status is-interactive; or return

# System shortcuts from CachyOS's fish config, as abbreviations: each expands to
# its full command, sudo included, before it runs. Deployed on Linux only.
command -q journalctl; and abbr --add jctl 'journalctl -p 3 -xb'
abbr --add psmem 'ps auxf | sort -nr -k 4'
abbr --add psmem10 'ps auxf | sort -nr -k 4 | head -10'
command -q hwinfo; and abbr --add hw 'hwinfo --short'
command -q grub-mkconfig; and abbr --add grubup 'sudo grub-mkconfig -o /boot/grub/grub.cfg'

# Arch and CachyOS packages.
command -q pacman; or return
abbr --add fixpacman 'sudo rm /var/lib/pacman/db.lck'
abbr --add cleanup 'sudo pacman -Rns (pacman -Qtdq)'
abbr --add gitpkg 'pacman -Qq | grep -ci -- -git'
if command -q expac
    abbr --add big "expac -H M '%m\t%n' | sort -h | nl"
    abbr --add rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
end
if command -q cachyos-rate-mirrors
    abbr --add mirror 'sudo cachyos-rate-mirrors'
    abbr --add update 'sudo cachyos-rate-mirrors && sudo pacman -Syu'
end
